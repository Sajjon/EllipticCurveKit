//
//  Curve.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-08.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public typealias Byte = UInt8

struct Point: Equatable {
    let x: Number
    let y: Number
    init(x: Number!, y: Number!) {
        self.x = x
        self.y = y
    }

    static func + (lhs: Point, rhs: Point) -> Point {
        var p1 = lhs
        var p2 = rhs

        func calculateLam() -> Number {
            var lam: Number

            if p1 == p2 {
                lam = 3 * p1.x * p1.x * pow(2 * p1.y, p - 2, p)
            } else {
                lam = (p2.y - p1.y) * pow(p2.x - p1.x, p - 2, p)
            }
            return lam % p
        }

        let lam = calculateLam()

        let x3 = (lam * lam - p1.x - p2.x) % p
        let y = (lam * (p1.x - x3) - p1.y) % p

        return Point(x: x3, y: y)
    }

    static func * (point: Point, number: Number) -> Point {
        return point_mul(point, number)
    }
}

public typealias HexString = String
struct PublicKeyPoint {

    let x: Number
    let y: Number
    let isYOdd: Bool

    static func prefixByteCompressed(isYOdd: Bool) -> Byte {
        return isYOdd ? 0x03 : 0x02
    }

    static func prefixByteUncompressed() -> Byte {
        return 0x04
    }

    func compressed() -> HexString {
        let prefixByte = PublicKeyPoint.prefixByteCompressed(isYOdd: isYOdd)
        let prefixAsTwoHexChars = String(format: "%02x", prefixByte)
        let hex = "\(prefixAsTwoHexChars)\(x.asHexStringLength64())"
        assert(hex.count == 66)
        return hex
    }

    func uncompressed() -> HexString {
        let prefixByte = PublicKeyPoint.prefixByteUncompressed()
        let prefixAsTwoHexChars = String(format: "%02x", prefixByte)
        let hex = "\(prefixAsTwoHexChars)\(x.asHexStringLength64())\(y.asHexStringLength64())"
        assert(hex.count == 130)
        return hex
    }

    init(point: Point) {
        self.x = point.x
        self.y = point.y
        self.isYOdd = point.y.isOdd()
    }
}

extension PublicKeyPoint {
    init(privateKey: PrivateKey) {
        let point = G * privateKey.number
        self.init(point: point)
    }
}

struct PrivateKey {
    let number: Number

    init(number: Number) {
        self.number = number
    }
}

extension PrivateKey {
    init(base64: Data) {
        self.init(number: Number(data: base64))
    }

    init?(base64: String) {
        guard let data = Data(base64Encoded: base64) else { return nil }
        self.init(base64: data)
    }

    init?(hex: String) {
        guard let number = Number(hexString: hex) else { return nil }
        self.init(number: number)
    }
}

extension PrivateKey {
    func base64Encoded() -> String {
        return number.asData().base64EncodedString()
    }
}

/// WIF == Wallet Import Format
struct PrivateKeysWIF {
    let compressed: Base58Encoded
    let uncompressed: Base58Encoded


    init(privateKey: PrivateKey, network: Network) {

        let prefixByte: Byte = network.privateKeyWifPrefix
        let prefix = Data([prefixByte])
        let suffixByte: Byte = network.privateKeyWifSuffix
        let suffix = Data([suffixByte])

        let privateKeyData = privateKey.number.asData()
        let keyWIFUncompressed = prefix + privateKeyData
        let keyWIFCompressed = prefix + privateKeyData + suffix

        let checkSumUncompressed = Crypto.sha2Sha256_twice(keyWIFUncompressed).prefix(4)
        let checkSumCompressed = Crypto.sha2Sha256_twice(keyWIFCompressed).prefix(4)

        let uncompressedData: Data = keyWIFUncompressed + checkSumUncompressed
        let compressedData: Data = keyWIFCompressed + checkSumCompressed

        self.compressed = Base58.encode(compressedData)
        self.uncompressed = Base58.encode(uncompressedData)
    }
}

public typealias Base58Encoded = String

enum Network {
    case testnet
    case mainnet

    var pubkeyhash: Byte {
        switch self {
        case .mainnet: return 0x00
        case .testnet: return 0x6f
        }
    }

    var privateKeyWifPrefix: Byte {
        switch self {
        case .mainnet: return 0x80
        case .testnet: return 0xef
        }
    }

    var privateKeyWifSuffix: Byte {
        return 0x01
    }
}


/// A Bitcoin address looks like 1MsScoe2fTJoq4ZPdQgqyhgWeoNamYPevy and is derived from an elliptic curve public key
/// plus a set of network parameters.
/// A standard address is built by taking the RIPE-MD160 hash of the public key bytes, with a version prefix and a
/// checksum suffix, then encoding it textually as base58. The version prefix is used to both denote the network for
/// which the address is valid.
struct PublicAddress {
    let hash: (uncompressed: Data, compressed: Data)
    let base58: (uncompressed: Base58Encoded, compressed: Base58Encoded)
    let zilliqa: HexString
    let network: Network

    /// Version = 1 byte of 0 (zero); on the test network, this is 1 byte of 111
    /// Key hash = Version concatenated with RIPEMD-160(SHA-256(public key))
    /// Checksum = 1st 4 bytes of SHA-256(SHA-256(Key hash))
    /// Bitcoin Address = Base58Encode(Key hash concatenated with Checksum)
    init(point: PublicKeyPoint, network: Network) {


        let uncompressedData = Data(hex: point.uncompressed())
        let compressedData = Data(hex: point.compressed())

        let zilliqaData = Crypto.sha2Sha256(compressedData)
        let number = Number(data: zilliqaData)
        let zilliqaDataString = number.asHexStringLength64()
        print(zilliqaDataString)
        let zilliqaAddress = String(zilliqaDataString.suffix(40))
        print(zilliqaAddress)
        self.zilliqa = zilliqaAddress

        let uncompressedHash = Data([network.pubkeyhash]) + Crypto.sha2Sha256_ripemd160(uncompressedData)
        let compressedHash = Data([network.pubkeyhash]) + Crypto.sha2Sha256_ripemd160(compressedData)
        let uncompressedBase58 = publicKeyHashToAddress(uncompressedHash)
        let compressedBase58 = publicKeyHashToAddress(compressedHash)
        self.hash = (uncompressed: uncompressedData, compressed: compressedData)
        self.base58 = (uncompressed: uncompressedBase58, compressed: compressedBase58)
        self.network = network
    }
}

/// Version = 1 byte of 0 (zero); on the test network, this is 1 byte of 111
/// Key hash = Version concatenated with RIPEMD-160(SHA-256(public key))
/// Checksum = 1st 4 bytes of SHA-256(SHA-256(Key hash))
/// Bitcoin Address = Base58Encode(Key hash concatenated with Checksum)
func publicKeyHashToAddress(_ hash: Data) -> String {
    let checksum = Crypto.sha2Sha256_twice(hash).prefix(4)
    let address = Base58.encode(hash + checksum)
    return address
}

let p = Number(hexString: "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F")!
let n = Number(hexString: "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")!
let x = Number(hexString: "0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798")!
let y = Number(hexString: "0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8")!
let G = Point(x: x, y: y)

func point_add(_ p1: Point?, _ p2: Point?) -> Point? {
    guard let p1 = p1 else { return p2 }
    guard let p2 = p2 else { return p1 }

    if p1.x == p2.x && p1.y != p2.y {
        return nil
    }

    return p1 + p2
}

func point_mul(_ p: Point, _ n: Number) -> Point {
    var n = n
    var p: Point? = p
    var r: Point!
    for i in 0..<256 { // n.bitWidth
        if n.magnitude[bitAt: i] {
            r = point_add(r, p)
        }
        p = point_add(p, p)
    }
    return r
}


/**
func sha256(_ b: XXX) -> XYX {
    return int.from_bytes(hashlib.sha256(b).digest(), byteorder="big")
}

 def on_curve(point):
    return (pow(point[1], 2, p) - pow(point[0], 3, p)) % p == 7

 def jacobi(x):
    return pow(x, (p - 1) // 2, p)

 def schnorr_sign(msg, seckey):
    k = sha256(seckey.to_bytes(32, byteorder="big") + msg)
    R = point_mul(G, k)
    if jacobi(R[1]) != 1:
        k = n - k
    e = sha256(R[0].to_bytes(32, byteorder="big") + bytes_point(point_mul(G, seckey)) + msg)
    return R[0].to_bytes(32, byteorder="big") + ((k + e * seckey) % n).to_bytes(32, byteorder="big")

 def schnorr_verify(msg, pubkey, sig):
    if (not on_curve(pubkey)):
        return False
    r = int.from_bytes(sig[0:32], byteorder="big")
    s = int.from_bytes(sig[32:64], byteorder="big")
    if r >= p or s >= n:
        return False
    e = sha256(sig[0:32] + bytes_point(pubkey) + msg)
    R = point_add(point_mul(G, s), point_mul(pubkey, n - e))
    if R is None or jacobi(R[1]) != 1 or R[0] != r:
        return False
    return True
 */
