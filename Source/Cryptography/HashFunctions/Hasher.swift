//
//  Hasher.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-09-21.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol Hasher: Hashing {
    func hash(_ data: DataConvertible) -> Data
}

public struct DefaultHasher: Hasher, ExpressibleByStringLiteral {
    public let function: HashFunction

    public init(function: HashFunction) {
        self.function = function
    }
}

// MARK: - Hasher Conformance
public extension DefaultHasher {
    func hash(_ data: DataConvertible) -> Data {
        return Crypto.hash(data, function: function)
    }
}

// MARK: - ExpressibleByStringLiteral Conformance
public extension DefaultHasher {

    init(stringLiteral name: String) {
        self.init(name: name)!
    }
}

// MARK: - Static Initialization
public extension DefaultHasher {
    static var sha256: DefaultHasher {
        return DefaultHasher(function: .sha256)
    }
}
