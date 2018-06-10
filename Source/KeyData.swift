//
//  KeyDataStruct.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-08.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public typealias KeyData = KeyDataStruct
public struct KeyDataStruct: KeyDataConvertible {
    public typealias Element = UInt8

    // Least significant element at index 0
    public private(set) var elements: [Element]

    public init(lsbZeroIndexed: [Element]) {
        self.elements = lsbZeroIndexed.droppingTrailingZeros()
    }
}

import BigInt
extension BigUInt: KeyDataConvertible {
    public typealias Element = Word
    public var elements: [Element] { return storage }
    public init(lsbZeroIndexed elements: [Element]) {
        self.init(words: elements)
    }
}
