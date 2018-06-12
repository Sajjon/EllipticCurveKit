//
//  KeyDataConvertible.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-05.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol KeyDataConvertible:
    UnsignedInteger,
    ExpressibleByArrayLiteral,
    ExpressibleByStringLiteral, // On Decimal format
    CustomDebugStringConvertible
    where
    Words: RandomAccessCollection,
    Words.Index == Int,
    Word == UInt
{
    associatedtype Word

    init(lsbZeroIndexed: [Word])
    init(msbZeroIndexed: [Word])
    init?(msbZeroIndexed: String, radix: Int)
}


public extension KeyDataConvertible {
    init(msbZeroIndexed: [Word]) {
        self.init(lsbZeroIndexed: Array(msbZeroIndexed.droppingLeadingZeros().reversed()))
    }
}

// MARK: - Convenience
public extension KeyDataConvertible {
    init?(msbZeroIndexed string: String) {
        self.init(msbZeroIndexed: string, radix: 16)
    }
}

// MARK: - ExpressibleByArrayLiteral
public extension KeyDataConvertible {
    init(arrayLiteral elements: Word...) {
        self.init(msbZeroIndexed: elements)
    }
}

// MARK: - CustomDebugStringConvertible
public extension KeyDataConvertible {
    public var debugDescription: String {
        return "Decimal: `\(description)`\nHex: `\(asHexString())`"
    }
}

// MARK: - Public Extension
public extension KeyDataConvertible {

    func toString(uppercased: Bool = true, radix: Int) -> String {
        let stringRepresentation = String(self, radix: radix)
        guard uppercased else { return stringRepresentation }
        return stringRepresentation.uppercased()
    }

    func asHexString(uppercased: Bool = true) -> String {
        return toString(uppercased: uppercased, radix: 16)
    }

    func asDecimalString(uppercased: Bool = true) -> String {
        return toString(uppercased: uppercased, radix: 10)
    }
}
