//
//  Message.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public extension String.Encoding {
    static var `default`: String.Encoding {
        return .ascii
    }
}

public struct Message: CustomStringConvertible {
    private let hashedData: Data
    public let hashedBy: Hasher

    public init(hashedData: Data, hashedBy hasher: Hasher) {
        self.hashedData = hashedData
        self.hashedBy = hasher
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

    init(unhashed: Data, hasher: Hasher) {
        self.init(hashedData: hasher.hash(unhashed), hashedBy: hasher)
    }

    init?(unhashed: String, encoding: String.Encoding = .default, hasher: Hasher) {
        guard let unhashedData = unhashed.data(using: encoding) else { return nil }
        self.init(unhashed: unhashedData, hasher: hasher)
    }

    init?(hashedHex: HexString, hashedBy hasher: Hasher) {
        self.init(hashedData: Data(hex: hashedHex), hashedBy: hasher)
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
