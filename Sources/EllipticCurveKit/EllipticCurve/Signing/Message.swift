//
//  Message.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import CryptoKit

public extension String.Encoding {
    static var `default`: String.Encoding {
        return .ascii
    }
}

public struct Message: CustomStringConvertible {
    private let hashedData: Data
    
    /// Make sure you know what you are doing, is this in fact hashed data? The data ought to be hashed
    /// before signed.
    public init(rawData: Data) {
        self.hashedData = rawData
    }

    public init<H>(hashedData: Data, hashedBy _: H) where H: HashFunction {
        self.hashedData = hashedData
    }
}

extension Message: Equatable {}
public extension Message {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.hashedData == rhs.hashedData
    }
}

// MARK: - Convenience Initializers
public extension Message {

    init<H>(unhashed: Data, hashFunction: H) where H: HashFunction {
        var hasher = hashFunction
        hasher.update(data: unhashed)
        
        self.init(hashedData: Data(hasher.finalize()), hashedBy: hasher)
    }

    init?<H>(
        unhashed: String,
        encoding: String.Encoding = .default,
        hashFunction: H
    ) where H: HashFunction {
        guard let unhashedData = unhashed.data(using: encoding) else { return nil }
        self.init(unhashed: unhashedData, hashFunction: hashFunction)
    }

    init?<H>(hashedHex: HexString, hashedBy hashFunction: H) where H: HashFunction {
        self.init(hashedData: Data(hex: hashedHex), hashedBy: hashFunction)
    }
}

public extension Message {

    var hexString: String {
        return hashedData.toHexString()
    }

    var description: String {
        return hexString
    }
}

extension Message: DataConvertible {
    public var asData: Data {
        return hashedData
    }
}
