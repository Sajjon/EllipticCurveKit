#!/usr/bin/env python3

import random
import hashlib
import base64
import base58
import binascii
from collections import namedtuple

class GaussInt:
    def __init__(self,x,y,n,p=0):
        if p:
            self.x=x%p
            self.y=y%p
            self.n=n%p
        else:
            self.x=x
            self.y=y
            self.n=n

        self.p=p
        
    def __add__(self,b):
        return GaussInt(self.x+b.x,self.y+b.y,self.n,self.p)
        
    def __sub__(self,b):
        return GaussInt(self.x-b.x,self.y-b.y,self.n,self.p)
    
    def __mul__(self,b):
        return GaussInt(self.x*b.x+self.n*self.y*b.y,self.x*b.y+self.y*b.x,self.n,self.p)
    
    def __div__(self,b):
        return GaussInt((self.x*b.x-self.n*self.y*b.y)/(b.x*b.x-self.n*b.y*b.y),(-self.x*b.y+self.y*b.x)/(b.x*b.x-self.n*b.y*b.y),self.n,self.p)
    
    def __eq__(self,b):
        return self.x==b.x and self.y==b.y
    
    def __repr__(self):
        if self.p:
            return "%s+%s (%d,%d)"%(self.x,self.y,self.n,self.p)
        else:
            return "%s+%s (%d)"%(self.x,self.y,self.n)
        
    def __pow__(self,n):
        b=Base(n,2)
        t=GaussInt(1,0,self.n)
        while b:
            t=t*t
            if b.pop():
                t=self*t
            
        return t

    def Inv(self):
        return GaussInt(self.x/(self.x*self.x-self.n*self.y*self.y),-self.y/(self.x*self.x-self.n*self.y*self.y),self.n,self.p)
        
    def Eval(self):
        return self.x.Eval()+self.y.Eval()*math.sqrt(self.n)   

def Cipolla(a,p):
    b=0
    while pow((b*b-a)%p,(p-1)/2,p)==1:
        b+=1

    return (GaussInt(b,1,b**2-a,p)**((p+1)/2)).x

def InvMod(a,n):
    m=[]

    s=n
    while n:
        m.append(a/n)
        (a,n)=(n,a%n)

    u=1
    v=0
    while m:
        (u,v)=(v,u-m.pop()*v)

    return u%s

def Base(n,b):
    l=[]
    while n:
        l.append(n%b)
        n/=b

    return l

def MsgMagic(message):
    return "\x18Bitcoin Signed Message:\n"+chr(len(message))+message

# def Hash(m,method):
#     h=hashlib.new(method)
#     h.update(m)

#     return h.digest()

def b58encode(v):
    #Encode a byte string to the Base58
    digit="123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    base=len(digit)
    val=0
    for c in v:
        val*=256
        val+=ord(c)

    result=""
    while val:
        (val,mod)=divmod(val,base)
        result=digit[mod]+result

    pad=0
    for c in v:
        if c=="\x00":
            pad+=1
        else:
            break
    
    return (digit[0]*pad)+result

# def b58decode(v):
#     #Decode a Base58 string to byte string
#     digit="123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
#     base=len(digit)
#     val=0    
#     for c in v:
#         val*=base
#         val+=digit.find(c)

#     result=""
#     while val:
#         (val,mod)=divmod(val,256)
#         result=chr(mod)+result

#     pad=0
#     for c in v:
#         if c==digit[0]:
#             pad+=1
#         else:
#             break

#     return "\x00"*pad+result

def b58decode_no_padding(v):
    #Decode a Base58 string to byte string
    digit="123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    base=len(digit)
    val=0    
    for c in v:
        val*=base
        val+=digit.find(c)

    result=""
    while val:
        (val,mod)=divmod(val,256)
        result=chr(mod)+result

    return result

def b58decode(v):
    #Decode a Base58 string to byte string
    digit="123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    base=len(digit)
    val=0    
    for c in v:
        val*=base
        val+=digit.find(c)

    result=""
    while val:
        (val,mod)=divmod(val,256)
        result=chr(mod)+result

    pad=0
    for c in v:
        if c==digit[0]:
            pad+=1
        else:
            break

    return "\x00"*pad+result

def Byte2Int(b):
    n=0
    for x in b:
        n*=256
        n+=ord(x)
    
    return n

def Byte2Hex(b):
    #Convert a byte string to hex number
    out=""
    for x in b:
        y=hex(ord(x))[2:]
        if len(y)==1:
            y="0"+y
        out+="%2s"%y
    
    return out

def Int2Byte(n,b):
    #Convert a integer to a byte string of length b
    out=""
    
    for _ in range(b):
        (n,m)=divmod(n,256)
        out=chr(int(m))+out
    
    return out

class EllipticCurvePoint:
    #Main class
    #It's a point on an Elliptic Curve

    def __init__(self,x,a,b,p,n=0):
        #We store the coordinate in x and the elliptic curve parameter.
        #x is of length 3. This is the 3 projective coordinates of the point.
        self.x=x[:]
        self.a=a
        self.b=b
        self.p=p
        self.n=n
    
    def __add__(self,y):
        #The main function to add self and y
        #It uses the formulas I derived in projective coordinates.
        #Projectives coordinates are more efficient than the usual (x,y) coordinates
        #because we don't need to compute inverse mod p, which is faster.
        z=EllipticCurvePoint([0,0,0],self.a,self.b,self.p)

        if self==y:
            d=(2*self.x[1]*self.x[2])%self.p
            d3=pow(d,3,self.p)
            n=(3*pow(self.x[0],2,self.p)+self.a*pow(self.x[2],2,self.p))%self.p
            
            z.x[0]=(pow(n,2,self.p)*d*self.x[2]-2*d3*self.x[0])%self.p
            z.x[1]=(3*self.x[0]*n*pow(d,2,self.p)-pow(n,3,self.p)*self.x[2]-self.x[1]*d3)%self.p
            z.x[2]=(self.x[2]*d3)%self.p
        else:
            d=(y.x[0]*self.x[2]-y.x[2]*self.x[0])%self.p
            d3=pow(d,3,self.p)
            n=(y.x[1]*self.x[2]-self.x[1]*y.x[2])%self.p

            z.x[0]=(y.x[2]*self.x[2]*pow(n,2,self.p)*d-d3*(y.x[2]*self.x[0]+y.x[0]*self.x[2]))%self.p
            z.x[1]=(pow(d,2,self.p)*n*(2*self.x[0]*y.x[2]+y.x[0]*self.x[2])-pow(n,3,self.p)*self.x[2]*y.x[2]-self.x[1]*d3*y.x[2])%self.p
            z.x[2]=(self.x[2]*d3*y.x[2])%self.p
        
        return z
    
    def __mul__(self,n):
        #The fast multiplication of point n times by itself.
        b=Base(n,2)
        t=EllipticCurvePoint(self.x,self.a,self.b,self.p)
        b.pop()
        while b:
            t+=t
            if b.pop():
                t+=self

        return t
    
    def __repr__(self):
        #print a point in (x,y) coordinate.
        return "x=%d\ny=%d\n"%((self.x[0]*InvMod(self.x[2],self.p))%self.p,(self.x[1]*InvMod(self.x[2],self.p))%self.p)
    
    def __eq__(self,y):
        #Does self==y ?
        #It computes self cross product with x and check if the result is 0.
        return self.x[0]*y.x[1]==self.x[1]*y.x[0] and self.x[1]*y.x[2]==self.x[2]*y.x[1] and self.x[2]*y.x[0]==self.x[0]*y.x[2] and self.a==y.a and self.b==y.b and self.p==y.p
    
    def __ne__(self,y):
        #Does self!=x ?
        return not (self == y)
    
    def Normalize(self):
        #Transform projective coordinates of self to the usual (x,y) coordinates.
        if self.x[2]:
            self.x[0]=(self.x[0]*InvMod(self.x[2],self.p))%self.p
            self.x[1]=(self.x[1]*InvMod(self.x[2],self.p))%self.p
            self.x[2]=1
        elif self.x[1]:
            self.x[0]=(self.x[0]*InvMod(self.x[1],self.p))%self.p
            self.x[1]=1
        elif self.x[0]:
            self.x[0]=1
        else:
            raise Exception

    def Check(self):
        #Is self on the curve ?
        return (self.x[0]**3+self.a*self.x[0]*self.x[2]**2+self.b*self.x[2]**3-self.x[1]**2*self.x[2])%self.p==0

    
    def CryptAddr(self,filename,password,Address):
        txt=""
        for tag in Address:
            (addr,priv)=Address[tag]
            if priv:
                txt+="%s\t%s\t%s\n"%(tag,addr,priv)
            else:
                txt+="%s\t%s\t\n"%(tag,addr)

        txt+="\x00"*(15-(len(txt)-1)%16)

        password+="\x00"*(15-(len(password)-1)%16)
        crypt=twofish.Twofish(password).encrypt(txt)

        f=open(filename,"wb")
        f.write(crypt)
        f.close()

    def GenerateD(self):
        #Generate a private key. It's just a random number between 1 and n-1.
        #Of course, this function isn't cryptographically secure.
        #Don't use it to generate your key. Use a cryptographically secure source of randomness instead.
        #return random.randint(1,self.n-1)
        return random.SystemRandom().randint(1,self.n-1) # Better random fix 

    def CheckECDSA(self,sig,message,Q):
        #Check a signature (r,s) of the message m using the public key self.Q
        # and the generator which is self.
        #This is not the one used by Bitcoin because the public key isn't known;
        # only a hash of the public key is known. See the function VerifyMessageFromAddress.
        (r,s)=sig
        
        if Q.x[2]==0:
            return False
        if not Q.Check():
            return False
        if (Q*self.n).x[2]!=0:
            return False
        if r<1 or r>self.n-1 or s<1 or s>self.n-1:
            return False

        z=Byte2Int(Hash(Hash(MsgMagic(message),"SHA256"),"SHA256"))
        
        w=InvMod(s,self.n)
        u1=(z*w)%self.n
        u2=(r*w)%self.n
        R=self*u1+Q*u2
        R.Normalize()

        return (R.x[0]-r)%self.n==0

    def SignMessage(self,message,priv):
        #Sign a message. The private key is self.d.
        (d,uncompressed)=self.DFromPriv(priv)

        z=Byte2Int(Hash(Hash(MsgMagic(message),"SHA256"),"SHA256"))
        
        r=0
        s=0
        while not r or not s:
            #k=random.randint(1,self.n-1)
            k=random.SystemRandom().randint(1,self.n-1) # Better random fix
            R=self*k
            R.Normalize()
            r=R.x[0]%self.n
            s=(InvMod(k,self.n)*(z+r*d))%self.n

        val=27
        if not uncompressed:
            val+=4

        return base64.standard_b64encode(chr(val)+Int2Byte(r,32)+Int2Byte(s,32))

    def VerifyMessageFromAddress(self,addr,message,sig):
        #Check a signature (r,s) for the message m signed by the Bitcoin 
        # address "addr".

        sign=base64.standard_b64decode(sig)
        (r,s)=(Byte2Int(sign[1:33]),Byte2Int(sign[33:65]))

        z=Byte2Int(Hash(Hash(MsgMagic(message),"SHA256"),"SHA256"))        

        val=ord(sign[0])
        if val<27 or val>=35:
            return False

        if val>=31:
            uncompressed=False
            val-=4
        else:
            uncompressed=True
        
        x=r
        y2=(pow(x,3,self.p) + self.a*x + self.b) % self.p
        y=Cipolla(y2,self.p)

        for _ in range(2):
            kG=EllipticCurvePoint([x,y,1],self.a,self.b,self.p,self.n)  
            mzG=self*((-z)%self.n)
            Q=(kG*s+mzG)*InvMod(r,self.n)
            
            if self.AddressFromPublicKey(Q,uncompressed)==addr:
                return True

            y=self.p-y

        return False

    def AddressFromPrivate(self,priv,should_base58_encode):
        #Transform a private key to a bitcoin address.
        (d,uncompressed)=self.DFromPriv(priv)
        
        return self.AddressFromD(d,uncompressed,should_base58_encode)

    def PrivFromD(self,d,uncompressed):
        #Encode a private key self.d to base58 encoding.
        p=Int2Byte(d,32)
        p="\x80"+p
        
        if not uncompressed:
            p+=chr(1)

        cs=Hash(Hash(p,"SHA256"),"SHA256")[:4]

        return b58encode(p+cs)
    
    def DFromPriv(self,priv):
        uncompressed=(len(priv)==51)
        priv=b58decode(priv)
        
        if uncompressed:
            priv=priv[:-4]
        else:
            priv=priv[:-5]
        
        return (Byte2Int(priv[1:]),uncompressed)

    # def AddressFromPublicKey(self,Q,uncompressed):
    #     #Find the bitcoin address from the public key self.Q
    #     #We do normalization to go from the projective coordinates to the usual
    #     # (x,y) coordinates.
    #     Q.Normalize()
    #     if uncompressed:
    #         pk=chr(4)+Int2Byte(Q.x[0],32)+Int2Byte(Q.x[1],32)
    #     else:
    #         pk=chr(2+Q.x[1]%2)+Int2Byte(Q.x[0],32)

    #     kh=chr(0)+Hash(Hash(pk,"SHA256"),"RIPEMD160")
    #     cs=Hash(Hash(kh,"SHA256"),"SHA256")[:4]

    #     return b58encode(kh+cs)

    def PublicKeyFromPrivateKeyAsBytes(self,priv):
        (d,uncompressed)=self.DFromPriv(priv)
        pk = self.PublicKeyFromD(d,uncompressed)
        return pk

    def PublicKeyFromPrivateKeyAs130CharHex(self,priv):
        return binascii.hexlify(self.PublicKeyFromPrivateKeyAsBytes(priv))

    def AddressFromD(self,d,uncompressed,should_base58_encode):
        #Computes a bitcoin address given the private key self.d.
        pk = self.PublicKeyFromD(d,uncompressed)
        return self.AddressFromPublicKey(pk,should_base58_encode)

    # def AddressFromPublicKey(self,Q,uncompressed,should_base58_encode):
    #     pk = self.CreatePublicKey(Q, uncompressed)

    #     kh=chr(0)+Hash(Hash(pk,"SHA256"),"RIPEMD160")
    #     cs=Hash(Hash(kh,"SHA256"),"SHA256")[:4]

    #     pubaddr=kh+cs

    #     if should_base58_encode:
    #         return b58encode(pubaddr)
    #     else:
    #         return binascii.hexlify(pubaddr)
    def AddressFromPublicKey(self,pk,should_base58_encode):
        assert 1 == 2 # make crash
        # kh=chr(0)+Hash(Hash(pk,"SHA256"),"RIPEMD160")
        # cs=Hash(Hash(kh,"SHA256"),"SHA256")[:4]

        # pubaddr=kh+cs

        # if should_base58_encode:
        #     return b58encode(pubaddr)
        # else:
        #     return binascii.hexlify(pubaddr)

    def PublicKeyFromD(self,d,uncompressed):
        return self.CreatePublicKey(self*d,uncompressed)

    def CreatePublicKey(self,Q,uncompressed):
        #Find the bitcoin address from the public key self.Q
        #We do normalization to go from the projective coordinates to the usual
        # (x,y) coordinates.
        Q.Normalize()
        if uncompressed:
            pk=chr(4)+Int2Byte(Q.x[0],32)+Int2Byte(Q.x[1],32)
        else:
            pk=chr(2+Q.x[1]%2)+Int2Byte(Q.x[0],32)
        return pk

    def IsValid(self,addr):
        adr=b58decode(addr)
        kh=adr[:-4]
        cs=adr[-4:]

        verif=Hash(Hash(kh,"SHA256"),"SHA256")[:4]

        return cs==verif

    # def AddressGenerator(self,k,uncompressed=True):
    #     #Generate Bitcoin address and write them in the multibit format.
    #     #Change the date as you like.
    #     liste={}
    #     for i in range(k):
    #         d=self.GenerateD()
    #         addr=self.AddressFromD(d,uncompressed)
    #         priv=self.PrivFromD(d,uncompressed)
    #         liste[i]=[addr,priv]
    #         print "%s %s"%(addr, priv)

    #     return liste

"""
Derive the public key of a secret key on the secp256k1 curve.

Args:
    public_key_point_x: An integer representing the public key points x component,
    public_key_point_y: An integer representing the public key points y component

Returns:
    Tuples of many public key formats

Raises:
    ValueError: The secret key is not in the valid range [1,N-1].
"""
# Keys = namedtuple('SevenFormatKeys', '1_priv_key_hex_64chars 2_priv_key_wif_base58_51chars 3_priv_key_wif_compressed_base58_52chars 4_pub_key_hex_130chars 5_pub_key_compressed_hex_66chars 6_pub_addr_base58_34chars 7_pub_addr_compressed_base58_34chars')
PrivateKeys = namedtuple('PrivateKeys', 'hex_64chars wif_base58_51chars wif_compressed_base58_52chars')
PublicKeys = namedtuple('PublicKeys', 'hex_130chars compressed_hex_66chars')
PublicAddresses = namedtuple('PublicAddresses', 'base58_34chars compressed_base58_34chars')
SevenFormats = namedtuple('SevenFormats', 'private_keys public_keys public_addresses')

def from_long(v, prefix, base, charset):
    """The inverse of to_long. Convert an integer to an arbitrary base.
    v: the integer value to convert
    prefix: the number of prefixed 0s to include
    base: the new base
    charset: an array indicating what printable character to use for each value.
    """
    l = bytearray()
    while v > 0:
        try:
            v, mod = divmod(v, base)
            l.append(charset(mod))
        except Exception:
            raise EncodingError("can't convert to character corresponding to %d" % mod)
    l.extend([charset(0)] * prefix)
    l.reverse()
    return bytes(l)

def to_bytes_32(v):
    v = from_long(v, 0, 256, lambda x: x)
    if len(v) > 32:
        raise ValueError("input to to_bytes_32 is too large")
    return ((b'\0' * 32) + v)[-32:]

# def bytetohex(byteStr):
#     return ''.join( [ "%02X" % x for x in byteStr ] ).strip()

def class_name(v):
    return type(v).__name__

def public_key_on_many_formats(privkey, public_key_point_x, public_key_point_y):
    key = to_bytes_32(privkey)
    public_x = public_key_point_x
    public_y = public_key_point_y

    public_key = b'\4' + to_bytes_32(public_x) + to_bytes_32(public_y)

    compressed_public_key = bytearray.fromhex("%02x%064x" % (2 + (public_y & 1), public_x))

    ## https://en.bitcoin.it/wiki/Technical_background_of_Bitcoin_addresses

    m = hashlib.new('ripemd160')
    m.update(hashlib.sha256(public_key).digest())
    ripe = m.digest() # Step 2 & 3

    m = hashlib.new('ripemd160')
    m.update(hashlib.sha256(compressed_public_key).digest())
    ripe_c = m.digest() # Step 2 & 3

    #litecoin = [b"\x30", b"\xb0"]
    bitcoin = [b"\x00", b"\x80"]
    # darkcoin = [b"\x4c", b"\xcc"]

    cointype = bitcoin

    extRipe = cointype[0] + ripe # Step 4
    extRipe_c = cointype[0] + ripe_c # Step 4


    chksum = hashlib.sha256(hashlib.sha256(extRipe).digest()).digest()[:4] # Step 5-7
    chksum_c = hashlib.sha256(hashlib.sha256(extRipe_c).digest()).digest()[:4] # Step 5-7

    addr = extRipe + chksum # Step 8
    addr_c = extRipe_c + chksum_c # Step 8

    public_key_uncompressed_130char_hex_uppercased = public_key.hex()
    public_key_compressed_66char_hex_uppercased = compressed_public_key.hex()
    public_address_uncompressed_base58 = base58.b58encode(addr).hex()
    public_address_compressed_base58 = base58.b58encode(addr_c).hex()

    ## WIF https://en.bitcoin.it/wiki/Wallet_import_format
    ## compressed WIF http://sourceforge.net/mailarchive/forum.php?thread_name=CAPg%2BsBhDFCjAn1tRRQhaudtqwsh4vcVbxzm%2BAA2OuFxN71fwUA%40mail.gmail.com&forum_name=bitcoin-development

    keyWIF = cointype[1] + key
    keyWIF_c = cointype[1] + key + b"\x01"
    
    chksum = hashlib.sha256(hashlib.sha256(keyWIF).digest()).digest()[:4]
    chksum_c = hashlib.sha256(hashlib.sha256(keyWIF_c).digest()).digest()[:4]

    addr = keyWIF + chksum # Step 8
    addr_c = keyWIF_c + chksum_c # Step 8
    # print("Private Key Hexadecimal Format (64 characters [0-9A-F]):", bytetohex(key))
    private_key_64chars_hex_uppercased = binascii.hexlify(key)
    # print("Private Key WIF (51 Base58 characters):", base58.b58encode(addr))
    private_key_wif_base58_51chars = base58.b58encode(addr)
    # print("Private Key WIF Compressed (52 Base58 characters):", base58.b58encode(addr_c),"\n")
    private_key_wif_compressed_base58_52chars = base58.b58encode(addr_c)

    private_keys = PrivateKeys(private_key_64chars_hex_uppercased, private_key_wif_base58_51chars, private_key_wif_compressed_base58_52chars)
    public_keys = PublicKeys(public_key_uncompressed_130char_hex_uppercased, public_key_compressed_66char_hex_uppercased)
    public_addresses = PublicAddresses(public_address_uncompressed_base58, public_address_compressed_base58)

    return SevenFormats(private_keys, public_keys, public_addresses)

"""
Derive the public key of a secret key on the secp256k1 curve.

Args:
    sk: An integer representing the secret key (also known as secret
      exponent).

Returns:
    Tuples of many public key formats

Raises:
    ValueError: The secret key is not in the valid range [1,N-1].
"""
def sk_to_pk_many_formats(private_key):
    pk_x, pk_y = sk_to_pk(private_key)
    return public_key_on_many_formats(private_key, pk_x, pk_y)

def sk_to_pk(sk):
    """
    Derive the public key of a secret key on the secp256k1 curve.

    Args:
        sk: An integer representing the secret key (also known as secret
          exponent).

    Returns:
        A coordinate (x, y) on the curve repesenting the public key
          for the given secret key.

    Raises:
        ValueError: The secret key is not in the valid range [1,N-1].
    """
    # base point (generator)
    G = (0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798,
         0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8)

    # field prime
    P = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F

    # order
    N = (1 << 256) - 0x14551231950B75FC4402DA1732FC9BEBF

    # check if the key is valid
    if not(0 < sk < N):
        msg = "{} is not a valid key (not in range [1, {}])"
        raise ValueError(msg.format(hex(sk), hex(N-1)))

    # addition operation on the elliptic curve
    # see: https://en.wikipedia.org/wiki/Elliptic_curve_point_multiplication#Point_addition
    # note that the coordinates need to be given modulo P and that division is
    # done by computing the multiplicative inverse, which can be done with
    # x^-1 = x^(P-2) mod P using fermat's little theorem (the pow function of
    # python can do this efficiently even for very large P)
    def add(p, q):
        px, py = p
        qx, qy = q
        if p == q:
            lam = (3 * px * px) * pow(2 * py, P - 2, P)
        else:
            lam = (qy - py) * pow(qx - px, P - 2, P)
        rx = lam**2 - px - qx
        ry = lam * (px - rx) - py
        return rx % P, ry % P

    # compute G * sk with repeated addition
    # by using the binary representation of sk this can be done in 256
    # iterations (double-and-add)
    ret = None
    for i in range(256):
        if sk & (1 << i):
            if ret is None:
                ret = G
            else:
                ret = add(ret, G)
        G = add(G, G)

    return ret

def Bitcoin():
    a=0
    b=7
    p=2**256-2**32-2**9-2**8-2**7-2**6-2**4-1
    Gx=int("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798",16)
    Gy=int("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8",16)
    n=int("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141",16)
    
    return EllipticCurvePoint([Gx,Gy,1],a,b,p,n)

def main():
    print("START")
    bitcoin=Bitcoin()
    # WIF stands for "Wallet Import Format"
    # In Bitcoin the WIFs begins with a leading char according to this formula
    # BTC WIF MAINNET
    ## uncompressed: `5`
    ## compressed: `K`
    # BTC WIF TESTNET
    ## uncompressed: `9`
    ## compressed: `L`

    expected_private_key_hex_64chars_uppercased = "29EE955FEDA1A85F87ED4004958479706BA6C71FC99A67697A9A13D9D08C618E"
    sevenFormats = sk_to_pk_many_formats(int(expected_private_key_hex_64chars_uppercased, 16))
    
    expected_private_key_uncompressed_wif_base58_51chars = "5J8kgEmHqTH9VYLd34DP6uGVmwbDXnQFQwDvZndVP4enBqz2GuM"
    expected_private_key_compressed_wif_base58_52chars = "KxdDnBkVJrzGUyKc45BeZ3hQ1Mx2JsPcceL3RiQ4GP7kSTX682Jj"
    expected_private_key_base64_44chars = "Ke6VX+2hqF+H7UAElYR5cGumxx/JmmdpepoT2dCMYY4="

    expected_public_key_uncompressed_130chars_hex_lowercased = "04f979f942ae743f27902b62ca4e8a8fe0f8a979ee3ad7bd0817339a665c3e7f4fb8cf959134b5c66bcc333a968b26d0adaccfad26f1ea8607d647e5b679c49184"
    expected_public_key_compressed_66chars_hex_lowercased = "02f979f942ae743f27902b62ca4e8a8fe0f8a979ee3ad7bd0817339a665c3e7f4f"

    expected_public_address_uncompressed = "157k4yFLw92XzCYysoS64hif6tcGdDULm6"
    expected_public_address_compressed = "1Dhtb2eZb3wq9kyUoY9oJPZXJrtPjUgDBU"

    expected_ZILLIQA_public_address_without_leading_0x = "59BB614648F828A3D6AFD7E488E358CDE177DAA0"

    assert expected_public_key_uncompressed_130chars_hex_lowercased == sevenFormats.public_keys.hex_130chars
    assert expected_public_key_compressed_66chars_hex_lowercased == sevenFormats.public_keys.compressed_hex_66chars

    print("DONE: Success")
    
if __name__ == "__main__": main()