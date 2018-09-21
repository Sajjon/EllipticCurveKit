//
//  HMAC.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-09-21.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol HMAC: Hashing {
    func hmac(key: DataConvertible, data: DataConvertible) throws -> Data
    var strength: Int { get }
}

public struct DefaultHMAC: HMAC {

    public let function: HashFunction

    public init(function: HashFunction) {
        self.function = function
    }

    public func hmac(key: DataConvertible, data: DataConvertible) throws -> Data {
        return try Crypto.hmac(key: key, data: data, function: function)
    }

    /// https://tools.ietf.org/html/rfc7630#section-4
    public var strength: Int {
        switch function {
        case .sha256: return 192
        }
    }
}
