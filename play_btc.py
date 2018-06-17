#!/usr/bin/env python3

import random
import hashlib
import base64
import base58
import binascii
from collections import namedtuple

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

def class_name(v):
    return type(v).__name__

PrivateKeys = namedtuple('PrivateKeys', 'hex_64chars wif_base58_51chars wif_compressed_base58_52chars')
PublicKeys = namedtuple('PublicKeys', 'hex_130chars compressed_hex_66chars')
PublicAddresses = namedtuple('PublicAddresses', 'base58_34chars compressed_base58_34chars zilliqa_public_address')
EightFormats = namedtuple('EightFormats', 'private_keys public_keys public_addresses')
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
    public_address_uncompressed_base58 = str(base58.b58encode(addr), 'utf-8')
    public_address_compressed_base58 = str(base58.b58encode(addr_c), 'utf-8')

    ## WIF https://en.bitcoin.it/wiki/Wallet_import_format
    ## compressed WIF http://sourceforge.net/mailarchive/forum.php?thread_name=CAPg%2BsBhDFCjAn1tRRQhaudtqwsh4vcVbxzm%2BAA2OuFxN71fwUA%40mail.gmail.com&forum_name=bitcoin-development

    keyWIF = cointype[1] + key
    keyWIF_c = cointype[1] + key + b"\x01"
    
    chksum = hashlib.sha256(hashlib.sha256(keyWIF).digest()).digest()[:4]
    chksum_c = hashlib.sha256(hashlib.sha256(keyWIF_c).digest()).digest()[:4]

    addr = keyWIF + chksum # Step 8
    addr_c = keyWIF_c + chksum_c # Step 8
    # print("Private Key Hexadecimal Format (64 characters [0-9A-F]):", bytetohex(key))
    private_key_64chars_hex_lowercased = key.hex()
    # print("Private Key WIF (51 Base58 characters):", base58.b58encode(addr))
    private_key_wif_base58_51chars = str(base58.b58encode(addr), 'utf-8')
    # print("Private Key WIF Compressed (52 Base58 characters):", base58.b58encode(addr_c),"\n")
    private_key_wif_compressed_base58_52chars = str(base58.b58encode(addr_c), 'utf-8')

    # Zilliqa Public address = RIGHTMOST 20 bytes of sha256(compressed_public_key)
    zilliqa_public_address = "0x" + hashlib.sha256(compressed_public_key).digest()[12:40].hex()

    private_keys = PrivateKeys(private_key_64chars_hex_lowercased, private_key_wif_base58_51chars, private_key_wif_compressed_base58_52chars)
    public_keys = PublicKeys(public_key_uncompressed_130char_hex_uppercased, public_key_compressed_66char_hex_uppercased)
    public_addresses = PublicAddresses(public_address_uncompressed_base58, public_address_compressed_base58, zilliqa_public_address)

    return EightFormats(private_keys, public_keys, public_addresses)

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

# def Bitcoin():
#     a=0
#     b=7
#     p=2**256-2**32-2**9-2**8-2**7-2**6-2**4-1
#     Gx=int("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798",16)
#     Gy=int("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8",16)
#     n=int("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141",16)
    
#     return EllipticCurvePoint([Gx,Gy,1],a,b,p,n)

def debug(value):
    print("Type: `%s`, value=`%s`" % (class_name(value), value))

def main():
    print("START")
    # bitcoin=Bitcoin()
    # WIF stands for "Wallet Import Format"
    # In Bitcoin the WIFs begins with a leading char according to this formula
    # BTC WIF MAINNET
    ## uncompressed: `5`
    ## compressed: `K`
    # BTC WIF TESTNET
    ## uncompressed: `9`
    ## compressed: `L`

    expected_private_key_hex_64chars_lowercased = "29ee955feda1a85f87ed4004958479706ba6c71fc99a67697a9a13d9d08c618e"
    eightFormats = sk_to_pk_many_formats(int(expected_private_key_hex_64chars_lowercased, 16))
    
    expected_private_key_uncompressed_wif_base58_51chars = "5J8kgEmHqTH9VYLd34DP6uGVmwbDXnQFQwDvZndVP4enBqz2GuM"
    expected_private_key_compressed_wif_base58_52chars = "KxdDnBkVJrzGUyKc45BeZ3hQ1Mx2JsPcceL3RiQ4GP7kSTX682Jj"
    # expected_private_key_base64_44chars = "Ke6VX+2hqF+H7UAElYR5cGumxx/JmmdpepoT2dCMYY4="

    expected_public_key_uncompressed_130chars_hex_lowercased = "04f979f942ae743f27902b62ca4e8a8fe0f8a979ee3ad7bd0817339a665c3e7f4fb8cf959134b5c66bcc333a968b26d0adaccfad26f1ea8607d647e5b679c49184"
    expected_public_key_compressed_66chars_hex_lowercased = "02f979f942ae743f27902b62ca4e8a8fe0f8a979ee3ad7bd0817339a665c3e7f4f"

    expected_public_address_uncompressed = "157k4yFLw92XzCYysoS64hif6tcGdDULm6"
    expected_public_address_compressed = "1Dhtb2eZb3wq9kyUoY9oJPZXJrtPjUgDBU"


    assert expected_public_key_uncompressed_130chars_hex_lowercased == eightFormats.public_keys.hex_130chars
    assert expected_public_key_compressed_66chars_hex_lowercased == eightFormats.public_keys.compressed_hex_66chars

    assert expected_private_key_hex_64chars_lowercased == eightFormats.private_keys.hex_64chars
    assert expected_private_key_uncompressed_wif_base58_51chars == eightFormats.private_keys.wif_base58_51chars
    assert expected_private_key_compressed_wif_base58_52chars == eightFormats.private_keys.wif_compressed_base58_52chars

    assert expected_public_address_uncompressed == eightFormats.public_addresses.base58_34chars
    assert expected_public_address_compressed == eightFormats.public_addresses.compressed_base58_34chars


    expected_ZILLIQA_public_address = "0x59bb614648f828a3d6afd7e488e358cde177daa0"
    assert expected_ZILLIQA_public_address == eightFormats.public_addresses.zilliqa_public_address

    print("DONE: Success")
    
if __name__ == "__main__": main()