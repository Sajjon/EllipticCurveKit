//
//  SignatureNonce+RFC-6979.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-19.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import CryptoSwift

func byteCount(fromBitCount: Int) -> Int {
    return Int(floor(Double((fromBitCount + 7)) / Double(8)))
}

extension Number {
    var byteCount: Int {
        return EllipticCurveKit.byteCount(fromBitCount: magnitude.bitWidth)
    }
}

public extension PrivateKey {
    func drbgRFC6979(message: Message) -> Number {
        return EllipticCurveKit.drbgRFC6979(privateKey: self, message: message)
    }
}

/// https://tools.ietf.org/html/rfc6979#section-3.2
public func drbgRFC6979<Curve>(privateKey: PrivateKey<Curve>, message: Message) -> Number {

    let hmac = DefaultHMAC(function: message.hashedBy.function)

    let byteCount = message.byteCount

    let x: DataConvertible = privateKey
    let qlen = Curve.order.magnitude.bitWidth

    // Step 3.2.a: "h1 = H(m)" - Already performed by the caller
    let h1: DataConvertible = message
    // Step 3.2.b: "V = 0x01 0x01 0x01 ... 0x01" - (n bytes equal 0x01)
    var V: DataConvertible = ByteArray(repeating: 0x01, count: byteCount)
    // Step 3.2.c. "K = 0x00 0x00 0x00 ... 0x00" - (n bytes equal 0x00)
    var K: DataConvertible = ByteArray(repeating: 0x00, count: byteCount)

    func HMAC_K(_ data: DataConvertible) -> Data {
        return try! hmac.hmac(key: K, data: data)
    }

    // Step 3.2.d: "K = HMAC_K(V || 0x00 || int2octets(x) || bits2octets(h1))"
    K = HMAC_K(V + 0x00 + x + h1)

    // Step 3.2.e: "V = HMAC_K(V)"
    V = HMAC_K(V)

    // Step 3.2.f: "K = HMAC_K(V || 0x01 || int2octets(x) || bits2octets(h1))"
    K = HMAC_K(V + 0x01 + x + h1)

    // Step 3.2.g. "V = HMAC_K(V)"
    V = HMAC_K(V)

    func bits2int(_ data: DataConvertible) -> Number {
        let x = Number(data)
        let l = x.magnitude.bitWidth
        if l > qlen {
            return x >> (l - qlen)
        }
        return x
    }
    // Step 3.2.h.
    // 3.2.h.1
    var T: DataConvertible
    var k: Number = 0
    repeat { // Note: the probability of not succeeding at the first try is about 2^-127.
        T = []

        // 3.2.h.2
        while T.byteCount < EllipticCurveKit.byteCount(fromBitCount: qlen) {
            V = HMAC_K(V)
            T = T + V
        }

        // 3.2.h.3
        k = bits2int(T)

        if k > 0 && k < Curve.order {
            break
        }

        K = HMAC_K(V + [0])
        V = HMAC_K(V)
    } while true

    return k
}

