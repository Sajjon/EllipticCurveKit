//
//  Hash.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-09-21.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol Hash: Hashing {
    func hash(_ data: DataConvertible) -> Data
}

public struct HashImpl: Hash, ExpressibleByStringLiteral {
    public let function: HashFunction

    public init(function: HashFunction) {
        self.function = function
    }

    public init(stringLiteral name: String) {
        self.init(name: name)!
    }

    public func hash(_ data: DataConvertible) -> Data {
        return Crypto.hash(data, function: function)
    }
}
