#!/usr/bin/env python2

# Use Python 2.7 not Python 3.X
# Downloaded from:
# https://github.com/HurlSly/BitcoinECCPython/blob/master/BitcoinECC.py

import random
import hashlib
import base64
# import base58
import binascii
from collections import namedtuple

# KEY CREATION
PointOnCurve = namedtuple('PointOnCurve', 'x y')

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

def Hash(m,method):
    h=hashlib.new(method)
    h.update(m)

    return h.digest()

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
        out=chr(m)+out
    
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

    def SignMessage(self, message, private_key_hex_64):
        #Sign a message. The private key is self.d.
        uncompressed = True
        d = self.DFromPrivateKeyHex64(private_key_hex_64)

        z = Byte2Int(Hash(Hash(MsgMagic(message), "SHA256"), "SHA256"))
        
        r = 0
        s = 0

        while not r or not s:
            #k=random.randint(1,self.n-1)
            k = random.SystemRandom().randint(1, self.n-1) # Better random fix
            R = self * k
            R.Normalize()
            r = R.x[0] % self.n
            s = (InvMod(k, self.n) * (z + r * d)) % self.n

        val = 27
        if not uncompressed:
            val+=4

        return base64.standard_b64encode(chr(val) + Int2Byte(r, 32) + Int2Byte(s, 32))

    def IsValid(self,addr):
        adr=b58decode(addr)
        kh=adr[:-4]
        cs=adr[-4:]

        verif=Hash(Hash(kh,"SHA256"),"SHA256")[:4]

        return cs==verif

    def VerifyMessageFromAddress(self, public_address_base58_uncompressed, message, sig):
        #Check a signature (r,s) for the message m signed by the Bitcoin 
        # address "addr".

        sign = base64.standard_b64decode(sig)
        (r, s) = (Byte2Int(sign[1:33]), Byte2Int(sign[33:65]))

        z = Byte2Int(Hash(Hash(MsgMagic(message), "SHA256"), "SHA256"))        

        val = ord(sign[0])
        if val < 27 or val >= 35:
            return False

        if val >= 31:
            uncompressed=False
            val -= 4
        else:
            uncompressed=True
        
        x = r
        y2 = (pow(x, 3, self.p) + self.a*x + self.b) % self.p
        y = Cipolla(y2, self.p)

        for _ in range(2):
            kG = EllipticCurvePoint([x,y,1],self.a,self.b,self.p,self.n)  
            mzG = self * ((-z) % self.n)
            Q = (kG * s + mzG) * InvMod(r, self.n)

            # def CalculatePublicKeyCurvePointFromPrivateKeyBytesD(self, d):
            #     private_key_point_Q = self * d
            #     return self.CalculatePublicKeyCurvePointFromPrivateKeyPointQ(private_key_point_Q)
            # def DeriveKeysAndAddressesFromPrivateKeyWifUncompressedOrCompressed(self, priv_wif_uncompressed):
            #     (private_key_D, _) = self.DFromPrivateKeyWifBase58Encoded(priv_wif_uncompressed)
            #     return self.DeriveKeysAndAddressesFromD(private_key_D)

            # def DeriveKeysAndAddressesFromD(self, private_key_D):
            #     private_key_byte_array = to_bytes_32(private_key_D)
            # return self.DeriveKeysAndAddressesFromPrivateKeyAsHex64Chars(private_key_byte_array)

            pubaddr_base58 = self.CreatePublicAddressBase58UncompressedFromQ(Q, uncompressed)
            print "pubaddr_base58 GENERATED"
            debug(pubaddr_base58)
            print "EXPECTED:"
            debug(public_address_base58_uncompressed)
            if pubaddr_base58 == public_address_base58_uncompressed:
                assert 1 == 2
                return True

            y = self.p - y

        return False

    def CreatePublicAddressBase58UncompressedFromQ(self, Q, uncompressed):
        public_keys = self.CreatePublicKeysFromQ(Q)

        public_key_uncompressed = public_keys.hex_130chars
        public_key_compressed = public_keys.compressed_hex_66chars
        # PUBLIC ADDRESSES
        m = hashlib.new('ripemd160')
        m.update(hashlib.sha256(public_key_uncompressed).digest())
        ripe = m.digest() # Step 2 & 3
    
        m = hashlib.new('ripemd160')
        m.update(hashlib.sha256(public_key_compressed).digest())
        ripe_c = m.digest() # Step 2 & 3
    
        bitcoin = [b"\x00", b"\x80"]
        # litecoin = [b"\x30", b"\xb0"]
        # darkcoin = [b"\x4c", b"\xcc"]
        cointype = bitcoin
    
        extRipe = cointype[0] + ripe # Step 4
        extRipe_c = cointype[0] + ripe_c # Step 4
    
        chksum = hashlib.sha256(hashlib.sha256(extRipe).digest()).digest()[:4] # Step 5-7
        chksum_c = hashlib.sha256(hashlib.sha256(extRipe_c).digest()).digest()[:4] # Step 5-7
    
        pubaddr = extRipe + chksum # Step 8
        pubaddr_c = extRipe_c + chksum_c # Step 8

        public_address_uncompressed_base58_25to34chars = b58encode(pubaddr) # OLD: str(b58encode(pubaddr), 'utf-8')
        public_address_compressed_base58_25to34chars = b58encode(pubaddr_c)

        print "START OF PUB ADD CREATION"
        debug(public_address_uncompressed_base58_25to34chars)
        debug(public_address_compressed_base58_25to34chars)
        print "END OF PUB ADD CREATION"

        if uncompressed:
        	return public_address_uncompressed_base58_25to34chars
        else:
        	return public_address_compressed_base58_25to34chars

    def CreatePublicKeysFromQ(self, Q):
        point = self.CalculatePublicKeyCurvePointFromPrivateKeyPointQ(Q)
        public_keys_tuple = self.PublicKeysFromPublicKeyCurvePoint(point)
        return public_keys_tuple

    
    def PrivateKeyWIFBase58UncompressedFromD(self, d):
        p=Int2Byte(d,32)
        p="\x80"+p

        cs=Hash(Hash(p,"SHA256"),"SHA256")[:4]

        private_key_wif_uncompressed = b58encode(p+cs)
        return private_key_wif_uncompressed
    
    def DFromPrivateKeyWifBase58Encoded(self, priv):
        uncompressed = (len(priv) == 51)
        priv = b58decode(priv)

        if uncompressed:
            priv = priv[:-4]
        else:
            priv = priv[:-5]

        return (self.DFromPrivateKeyWif(priv), uncompressed)

    def DFromPrivateKeyWif(self,priv):
        return self.DFromPrivK(priv[1:])

    def DFromPrivateKeyHex64(self, sk):
        return self.DFromPrivK(sk)

    def DFromPrivK(self,priv):
        return Byte2Int(priv)

    def PublicKeyAsHex130CharsFromPrivateHex64Chars(self, private_key_hex_64):
        return binascii.hexlify(self.PublicKeyFromPrivateKeyAsBytes(private_key_hex_64))

    def PublicKeysFromPublicKeyCurvePoint(self, public_key_curve_point):
        pk_x = public_key_curve_point.x
        pk_y = public_key_curve_point.y
        pkx_bytes = int(binascii.hexlify(pk_x), 16)
        pky_bytes = int(binascii.hexlify(pk_y), 16) 
        
        uncompressed = chr(4) + pk_x + pk_y
        compressed =  chr(2 + (pky_bytes & 1)) + pk_x

        public_key_uncompressed_130char_hex_uppercased = uncompressed
        public_key_compressed_66char_hex_uppercased = compressed

        return PublicKeys(public_key_uncompressed_130char_hex_uppercased, public_key_compressed_66char_hex_uppercased)

    def DeriveKeysAndAddressesFromPrivateKeyWifUncompressedOrCompressed(self, priv_wif_uncompressed):
        (private_key_D, _) = self.DFromPrivateKeyWifBase58Encoded(priv_wif_uncompressed)
        return self.DeriveKeysAndAddressesFromD(private_key_D)

    def DeriveKeysAndAddressesFromD(self, private_key_D):
        private_key_byte_array = to_bytes_32(private_key_D)
        return self.DeriveKeysAndAddressesFromPrivateKeyAsHex64Chars(private_key_byte_array)

    # Code found here: https://gist.github.com/UdjinM6/07f1feae8b7495c67480
    # should be updated to use vanilla 
    def DeriveKeysAndAddressesFromPrivateKeyAsHex64Chars(self, private_key_bytes_array):
        public_key_curve_point = self.CalculatePublicKeyCurvePointFromPrivateKeyHex64Chars(private_key_bytes_array)    
        intermediate_pubkeys = self.PublicKeysFromPublicKeyCurvePoint(public_key_curve_point)

        public_key_uncompressed = intermediate_pubkeys.hex_130chars
        public_key_compressed = intermediate_pubkeys.compressed_hex_66chars

        private_key = private_key_bytes_array

        # PUBLIC ADDRESSES
        m = hashlib.new('ripemd160')
        m.update(hashlib.sha256(public_key_uncompressed).digest())
        ripe = m.digest() # Step 2 & 3
    
        m = hashlib.new('ripemd160')
        m.update(hashlib.sha256(public_key_compressed).digest())
        ripe_c = m.digest() # Step 2 & 3
    
        bitcoin = [b"\x00", b"\x80"]
        # litecoin = [b"\x30", b"\xb0"]
        # darkcoin = [b"\x4c", b"\xcc"]
        cointype = bitcoin
    
        extRipe = cointype[0] + ripe # Step 4
        extRipe_c = cointype[0] + ripe_c # Step 4
    
        chksum = hashlib.sha256(hashlib.sha256(extRipe).digest()).digest()[:4] # Step 5-7
        chksum_c = hashlib.sha256(hashlib.sha256(extRipe_c).digest()).digest()[:4] # Step 5-7
    
        pubaddr = extRipe + chksum # Step 8
        pubaddr_c = extRipe_c + chksum_c # Step 8

        public_address_uncompressed_base58_25to34chars = b58encode(pubaddr) # OLD: str(b58encode(pubaddr), 'utf-8')
        public_address_compressed_base58_25to34chars = b58encode(pubaddr_c)

        # Zilliqa Public address = RIGHTMOST 20 bytes of sha256(compressed_public_key)
        zilliqa_public_address = "0x" + binascii.hexlify(hashlib.sha256(public_key_compressed).digest()[12:40]) # foobarbarbarbarbarbuzbuzfoobarbuzbuz.hex()

        public_addresses_on_three_formats = PublicAddresses(public_address_uncompressed_base58_25to34chars, public_address_compressed_base58_25to34chars, zilliqa_public_address)
    
        # PRIVATE KEY WALLET IMPORT FORMAT
        keyWIF = cointype[1] + private_key
        keyWIF_c = cointype[1] + private_key + b"\x01"
        
        chksum = hashlib.sha256(hashlib.sha256(keyWIF).digest()).digest()[:4]
        chksum_c = hashlib.sha256(hashlib.sha256(keyWIF_c).digest()).digest()[:4]
    
        secaddr = keyWIF + chksum # Step 8
        secaddr_c = keyWIF_c + chksum_c # Step 8
        private_key_wif_base58_51chars = b58encode(secaddr)
        private_key_wif_compressed_base58_52chars = b58encode(secaddr_c)

        private_keys_on_three_formats = PrivateKeys(binascii.hexlify(private_key), private_key_wif_base58_51chars, private_key_wif_compressed_base58_52chars)
        public_keys = PublicKeys(binascii.hexlify(public_key_uncompressed), binascii.hexlify(public_key_compressed))

        # ASSERT CORRECT FORMATTING
        f8 = EightFormats(private_keys_on_three_formats, public_keys, public_addresses_on_three_formats)
        assert isinstance(f8.private_keys.hex_64chars, str)
        assert 64 == len(f8.private_keys.hex_64chars)

        assert isinstance(f8.private_keys.wif_base58_51chars, str)
        assert 51 == len(f8.private_keys.wif_base58_51chars)

        assert isinstance(f8.private_keys.wif_compressed_base58_52chars, str)
        assert 52 == len(f8.private_keys.wif_compressed_base58_52chars)

        assert isinstance(f8.public_keys.hex_130chars, str)
        assert 130 == len(f8.public_keys.hex_130chars)

        assert isinstance(f8.public_keys.compressed_hex_66chars, str)
        assert 66 == len(f8.public_keys.compressed_hex_66chars)

        assert isinstance(f8.public_addresses.base58_25to34chars, str)
        length = len(f8.public_addresses.base58_25to34chars)
        assert 25 <= length <= 34

        assert isinstance(f8.public_addresses.compressed_base58_25to34chars, str)
        length = len(f8.public_addresses.compressed_base58_25to34chars)
        assert 25 <= length <= 34

        assert f8.public_addresses.compressed_base58_25to34chars != f8.public_addresses.base58_25to34chars, "Compressed and non compressed public address should not be equal"

        assert isinstance(f8.public_addresses.zilliqa_public_address, str)
        assert 42 == len(f8.public_addresses.zilliqa_public_address)

        # TEST SIGNING MESSAGE
        message_to_sign = "This python code is soon gonna be ported to Swift, yay!!!"
        self.TestSigningMessage(f8.private_keys.hex_64chars, f8.public_addresses.base58_25to34chars, message_to_sign)

        return f8

    def TestSigningMessage(self, private_key_64, public_address_base58_uncompressed, message):
        #Sign a message with the current address
        signature = self.SignMessage(message, private_key_64)
        #Verify the message using only the bitcoin adress, the signature and the message.
        #Not using the public key as it is not needed.
        print "Signing message with private key:"
        debug(private_key_64)
        print "Verifying with pub addr:"
        debug(public_address_base58_uncompressed)
        assert self.VerifyMessageFromAddress(public_address_base58_uncompressed, message, signature), "Should verify"

    def CalculatePublicKeyCurvePointFromPrivateKeyHex64Chars(self, privkey_hex_64):
        private_key_bytes_D = self.DFromPrivateKeyHex64(privkey_hex_64)
        return self.CalculatePublicKeyCurvePointFromPrivateKeyBytesD(private_key_bytes_D)

    def CalculatePublicKeyCurvePointFromPrivateKeyBytesD(self, d):
        private_key_point_Q = self * d
        return self.CalculatePublicKeyCurvePointFromPrivateKeyPointQ(private_key_point_Q)

    def CalculatePublicKeyCurvePointFromPrivateKeyPointQ(self, Q):
        #Find the bitcoin address from the public key self.Q
        #We do normalization to go from the projective coordinates to the usual
        # (x,y) coordinates.
        Q.Normalize()
        pk_x = Int2Byte(Q.x[0], 32)
        pk_y = Int2Byte(Q.x[1], 32)
        return PointOnCurve(pk_x, pk_y)

    def AddressGenerator(self, k):
        my_list = []
        for i in range(k):
            d = self.GenerateD()
            private_key_wif_uncompressed = self.PrivateKeyWIFBase58UncompressedFromD(d)
            format8 = self.DeriveKeysAndAddressesFromPrivateKeyWifUncompressedOrCompressed(private_key_wif_uncompressed)
            my_list.append(format8)

        return my_list

def Bitcoin():
    a=0
    b=7
    p=2**256-2**32-2**9-2**8-2**7-2**6-2**4-1
    Gx=int("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798",16)
    Gy=int("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8",16)
    n=int("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141",16)
    
    return EllipticCurvePoint([Gx,Gy,1],a,b,p,n)


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

### KEY DERIVATION
def class_name(v):
    return type(v).__name__

PrivateKeys = namedtuple('PrivateKeys', 'hex_64chars wif_base58_51chars wif_compressed_base58_52chars')
PublicKeys = namedtuple('PublicKeys', 'hex_130chars compressed_hex_66chars')
PublicAddresses = namedtuple('PublicAddresses', 'base58_25to34chars compressed_base58_25to34chars zilliqa_public_address')
EightFormats = namedtuple('EightFormats', 'private_keys public_keys public_addresses')

def debug(value):
    print("Type: `%s`, value=`%s`" % (class_name(value), value))


# TESTS
expected_private_key_hex_64chars_lowercased = "29ee955feda1a85f87ed4004958479706ba6c71fc99a67697a9a13d9d08c618e"
expected_private_key_uncompressed_wif_base58_51chars = "5J8kgEmHqTH9VYLd34DP6uGVmwbDXnQFQwDvZndVP4enBqz2GuM"
expected_private_key_compressed_wif_base58_52chars = "KxdDnBkVJrzGUyKc45BeZ3hQ1Mx2JsPcceL3RiQ4GP7kSTX682Jj"
# expected_private_key_base64_44chars = "Ke6VX+2hqF+H7UAElYR5cGumxx/JmmdpepoT2dCMYY4="

expected_public_key_uncompressed_130chars_hex_lowercased = "04f979f942ae743f27902b62ca4e8a8fe0f8a979ee3ad7bd0817339a665c3e7f4fb8cf959134b5c66bcc333a968b26d0adaccfad26f1ea8607d647e5b679c49184"
expected_public_key_compressed_66chars_hex_lowercased = "02f979f942ae743f27902b62ca4e8a8fe0f8a979ee3ad7bd0817339a665c3e7f4f"

expected_public_address_uncompressed = "157k4yFLw92XzCYysoS64hif6tcGdDULm6"
expected_public_address_compressed = "1Dhtb2eZb3wq9kyUoY9oJPZXJrtPjUgDBU"
expected_ZILLIQA_public_address = "0x59bb614648f828a3d6afd7e488e358cde177daa0"

def test_8_formats_using_private_key_hex64char(private_key_64):
    test_8_formats(Bitcoin().DeriveKeysAndAddressesFromPrivateKeyAsHex64Chars(private_key_64))
    print "TEST verifying 8 formats from private key 64 PASSED"

def test_8_formats_using_private_key_wif_uncompressed(private_key_wif_uncompressed):
    test_8_formats(Bitcoin().DeriveKeysAndAddressesFromPrivateKeyWifUncompressedOrCompressed(private_key_wif_uncompressed))
    print "TEST verifying 8 formats from private key WIF uncompressed PASSED"

def test_8_formats_using_private_key_wif_compressed(private_key_wif_compressed):
    test_8_formats(Bitcoin().DeriveKeysAndAddressesFromPrivateKeyWifUncompressedOrCompressed(private_key_wif_compressed))
    print "TEST verifying 8 formats from private key WIF compressed PASSED"

def test_8_formats(eightFormats):
    assert expected_public_key_uncompressed_130chars_hex_lowercased == eightFormats.public_keys.hex_130chars
    assert expected_public_key_compressed_66chars_hex_lowercased == eightFormats.public_keys.compressed_hex_66chars

    assert expected_private_key_hex_64chars_lowercased == eightFormats.private_keys.hex_64chars
    assert expected_private_key_uncompressed_wif_base58_51chars == eightFormats.private_keys.wif_base58_51chars
    assert expected_private_key_compressed_wif_base58_52chars == eightFormats.private_keys.wif_compressed_base58_52chars

    assert expected_public_address_uncompressed == eightFormats.public_addresses.base58_25to34chars
    assert expected_public_address_compressed == eightFormats.public_addresses.compressed_base58_25to34chars

    assert expected_ZILLIQA_public_address == eightFormats.public_addresses.zilliqa_public_address

def test_calc_privkey_D_from_privkey_wif(privkey, privkey_wif, privkey_wif_compressed):
    bitcoin = Bitcoin()
    (d_wif_uncompressed, _) = bitcoin.DFromPrivateKeyWifBase58Encoded(expected_private_key_uncompressed_wif_base58_51chars)
    (d_wif_compressed, _) = bitcoin.DFromPrivateKeyWifBase58Encoded(expected_private_key_compressed_wif_base58_52chars)
    d = bitcoin.DFromPrivateKeyHex64(privkey)
    assert d == d # trivial
    assert d_wif_uncompressed == d_wif_compressed
    assert d == d_wif_compressed
    assert d == d_wif_uncompressed # trivial
    print "TEST privkey D calculation PASSED"

def print_eight_formats_info(f8):
    print "Private key 64 hex: %s\nPrivate Key WIF uncompressed: %s\nPrivate Key WIF compressed: %s\nPublic Key Uncompressed: %s\nPublic Key Compressed: %s\nPublic Address Uncompressed: %s\nPublic Address Compressed: %s\nPublic Address ZILLIQA: %s\n" % (f8.private_keys.hex_64chars, f8.private_keys.wif_base58_51chars, f8.private_keys.wif_compressed_base58_52chars, f8.public_keys.hex_130chars, f8.public_keys.compressed_hex_66chars, f8.public_addresses.base58_25to34chars, f8.public_addresses.compressed_base58_25to34chars, f8.public_addresses.zilliqa_public_address) 

def test_generating_printing_new_addresses(count, print_info_for_all=False):
    generated = Bitcoin().AddressGenerator(count)
    print "Generated %d new wallets" % (count)
    for f8 in generated:
        if print_info_for_all:
            print "\n\nPRINTING NEW KEY ON EIGHT FORMATS\n"
            print_eight_formats_info(f8)

    print "TEST creating %d new addresses PASSED" % (count)

def run_tests():
    private_key_64 = binascii.unhexlify(expected_private_key_hex_64chars_lowercased)

    # TEST 0 - WIF import
    test_calc_privkey_D_from_privkey_wif(private_key_64, expected_private_key_uncompressed_wif_base58_51chars, expected_private_key_compressed_wif_base58_52chars)

    # TEST 1 - Private Key as Hex string, 64 chars to all other formats
    test_8_formats_using_private_key_hex64char(private_key_64)

    # TEST 2 - Private Key WIF Base58 encoded Uncompressed to all other formats
    test_8_formats_using_private_key_wif_uncompressed(expected_private_key_uncompressed_wif_base58_51chars)
    test_8_formats_using_private_key_wif_compressed(expected_private_key_compressed_wif_base58_52chars)

    test_generating_printing_new_addresses(count=100, print_info_for_all=False)
    print "ALL TESTS PASSED :D"

def main():
    run_tests()
    
if __name__ == "__main__": main()