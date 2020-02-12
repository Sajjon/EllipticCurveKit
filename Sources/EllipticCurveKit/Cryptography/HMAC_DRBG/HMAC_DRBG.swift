//
//  HMAC_DRBG.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-09-17.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import CryptoKit

typealias ByteArray = [Byte]

/// 2^48, which is NIST's recommended value
private let reseedInterval: Number = 0x1000000000000

/// HMAC_DRBG is a Deterministic Random Bit Generator (DRBG) using HMAC as hash function.
public final class HMAC_DRBG {

    private var K: DataConvertible
    private var V: DataConvertible
    private let minimumEntropyByteCount: Int
    private var iterationsLeftUntilReseed: Number

    public init(
        entropy: DataConvertible,
        nonce: DataConvertible,
        personalization: DataConvertible? = nil,
        additionalInput: DataConvertible? = nil
    ) {
        self.iterationsLeftUntilReseed = reseedInterval
        
         // for SHA256 it is 192: https://tools.ietf.org/html/rfc7630#section-4
        self.minimumEntropyByteCount = 192
        let byteCount = 32 // 256 bits => 32 bytes

        self.K = Data(repeating: 0x00, count: byteCount)
        self.V = Data(repeating: 0x01, count: byteCount)

        let seed = entropy + nonce + personalization
        updateSeed(seed)
    }
}

// MARK: - Errors
public extension HMAC_DRBG {
    enum Error: Swift.Error {
        case notEnoughEntropy(byteCountProvidedEntropy: Int, byteCountMinimumRequiredEntropy: Int)
        case reseedNeeded
    }
}


public extension HMAC_DRBG {
    convenience init<Curve>(
        message: Message,
        privateKey: PrivateKey<Curve>,
        personalization: DataConvertible?
    ) {
        self.init(
            entropy: privateKey,
            nonce: message,
            personalization: personalization
        )
    }

    func generateNumberOfLength(byteCount: Int, additionalData: Data? = nil) throws -> Data {
        try generateNumberOfLength(byteCount, additionalData: additionalData).result
    }

    func reseed(entropy: Data, additionalData: Data = Data()) throws {
        guard entropy.count >= minimumEntropyByteCount else {
            throw Error.notEnoughEntropy(byteCountProvidedEntropy: entropy.count, byteCountMinimumRequiredEntropy: minimumEntropyByteCount)
        }
        updateSeed(entropy + additionalData)
        iterationsLeftUntilReseed = reseedInterval
    }
}

extension HMAC_DRBG {
    /// Psuedocode at page 5: https://eprint.iacr.org/2018/349.pdf
    /// Return value `state` is only used by unit tests
    func generateNumberOfLength(_ byteCount: Int, additionalData: Data? = nil) throws -> (result: Data, state: KeyValue) {
        guard iterationsLeftUntilReseed > 0 else { throw Error.reseedNeeded }

        if let additionalData = additionalData {
            updateSeed(additionalData)
        }

        var generated = Data()
        while generated.count < byteCount {
            V = HMAC_K(V)
            generated += V.asData
        }
        generated = generated.prefix(byteCount)
        updateSeed(additionalData)
        iterationsLeftUntilReseed -= 1
        return (result: generated, state: KeyValue(v: V.asHex, key: K.asHex))
    }
}

private extension HMAC_DRBG {

    func updateSeed(_ _seed: Data? = nil) {
        let seed = _seed ?? Data()
        func update(_ magicByte: Byte) {
            K = HMAC_K(V + magicByte + seed)
            V = HMAC_K(V)
        }
        update(0x00)
        if _seed == nil { return }
        update(0x01)
    }

    func HMAC_K(_ data: DataConvertible) -> Data {
        var hmac = HMAC<SHA256>.init(key: .init(data: self.K.asData))
        hmac.update(data: data.asData)
        return Data(hmac.finalize())
    }
}
