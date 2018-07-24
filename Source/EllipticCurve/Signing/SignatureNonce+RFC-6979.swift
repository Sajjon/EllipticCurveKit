//
//  SignatureNonce+RFC-6979.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-19.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import CryptoSwift

func byteCount(of bitsCount: Int) -> Int {
    return Int(floor(Double((bitsCount + 7)) / Double(8)))
}

extension PrivateKey {

    /// https://tools.ietf.org/html/rfc6979#section-3.2
    func signatureNonceK(forHashedData hashedData: Data, digestLength: Int? = nil) -> Number {

        let hashFunctionUsedToHashInputDataDigestLength = digestLength ?? CryptoSwift.SHA2.Variant.sha256.digestLength

        let privateKey = self
        let privateKeyData = asData()
        let x = privateKeyData.bytes
        let order = Curve.order
        let qlen = order.magnitude.bitWidth

        // Step 3.2.a: "h1 = H(m)" - Already performed by the caller
        let h1 = hashedData.bytes
        // Step 3.2.b: "V = 0x01 0x01 0x01 ... 0x01" - (32 bytes equal 0x01)
        var V = [UInt8](repeating: 0x01, count: hashFunctionUsedToHashInputDataDigestLength)
         // Step 3.2.c. "K = 0x00 0x00 0x00 ... 0x00" - (32 bytes equal 0x00)
        var K = [UInt8](repeating: 0x00, count: hashFunctionUsedToHashInputDataDigestLength)

        func hmac(_ data: [Byte]) -> [Byte] {
            return try! Crypto.hmacSha256(key: K, data: data)
        }

        // Step 3.2.d: "K = HMAC_K(V || 0x00 || int2octets(x) || bits2octets(h1))"
        K = hmac(V + [0] + x + h1)

        // Step 3.2.e: "V = HMAC_K(V)"
        V = hmac(V)

        // Step 3.2.f: "K = HMAC_K(V || 0x01 || int2octets(x) || bits2octets(h1))"
        K = hmac(V + [1] + x + h1)

        // Step 3.2.g. "V = HMAC_K(V)"
        V = hmac(V)

        func bits2int(_ bytes: [Byte]) -> Number {
            let data = Data(bytes: bytes)
            let x = Number(data: data)
            let l = x.magnitude.bitWidth
            if l > qlen {
                return x >> (l - qlen)
            }
            return x
        }
        // Step 3.2.h.
        // 3.2.h.1
        var T: [Byte]
        var k: Number = 0
        repeat { // Note: the probability of not succeeding at the first try is about 2^-127.
            T = []

            // 3.2.h.2
            while T.count < byteCount(of: qlen) {
                V = hmac(V)
                T = T + V
            }

            // 3.2.h.3
            k = bits2int(T)

            if k > 0 && k < order {
                break
            }

            K = hmac(V + [0])
            V = hmac(V)
        } while true

        return k
    }
}
