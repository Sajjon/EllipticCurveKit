//
//  HMACUpdatable.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-09-17.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import CryptoSwift

struct HMACUpdatable {

    private var _digest: ByteArray
    private let hmac: HMAC
    private let hashType: HashType

    init(key: ByteArray, data: ByteArray?, hash: HashType = .sha2sha256) {
        self.hashType = hash
        let variant = hash.hmac
        let hmac = HMAC(key: key, variant: variant)
        if let data = data {
            let digest = try! hmac.authenticate(data)
            self.hmac = HMAC(key: digest)
            self._digest = digest
        } else {
            _digest = key
            self.hmac = hmac
        }
    }

    func digest() -> ByteArray {
        return _digest
    }
    func update(_ bytes: ByteArray) -> HMACUpdatable {
        return HMACUpdatable(key: _digest, data: bytes, hash: hashType)
    }
}
extension HMACUpdatable {
    init(key: Data, data: Data?, hash: HashType = .sha2sha256) {
        self.init(key: key.bytes, data: data?.bytes, hash: hash)
    }
    init(key: Data, data: String, encoding: String.Encoding = .utf8, hash: HashType = .sha2sha256) {
        self.init(key: key, data: data.data(using: encoding), hash: hash)
    }
    init(key: String, data: String, encoding: String.Encoding = .utf8, hash: HashType = .sha2sha256) {
        guard let key = key.data(using: encoding) else { fatalError("unhandled") }
        self.init(key: key, data: data, encoding: encoding, hash: hash)
    }

    func hexDigest() -> String {
        return Data(digest()).toHexString()
    }
}

extension HMACUpdatable: DataConvertible {
    var asData: Data {
        return Data(digest())
    }
    init(data: Data) {
        fatalError()
    }
}
