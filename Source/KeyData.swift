//
//  KeyData.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-05.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct KeyData {
    public typealias Element = UInt8

    // Least significant element at index 0
    public private(set) var elements: [Element]

    public init(_ elements: [Element]) {
        self.elements = elements
    }

    public enum Error: Int, Swift.Error {
        case invalidString
    }
}

// MARK: - Convenience Init
public extension KeyData {
    init(hexString: String) throws {
        let string = hexString.dropTwoLeadinHexCharsIfNeeded()
        let arrayOfHex = string.splitIntoSubStringsOfLength(2) // 16^2 = 256 bits
        let array = arrayOfHex.compactMap { Element($0, radix: 16) }
        guard arrayOfHex.count == array.count else { throw Error.invalidString }
        self.init(array)
    }
}

// MARK: -
extension KeyData: ExpressibleByArrayLiteral {}
public extension KeyData {
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

// MARK: - Collection
extension KeyData: Collection {}
public extension KeyData {
    typealias Index = Int

    var startIndex: Int {
        return elements.startIndex
    }

    var endIndex: Int {
        return elements.endIndex
    }

    subscript(position: Int) -> Element {
        return elements[position]
    }

    func index(after i: Int) -> Int {
        return elements.index(after: i)
    }
}

// MARK: - CustomStringConvertible
extension KeyData: CustomStringConvertible {}
public extension KeyData {
    public var description: String {
        return elements.map { "\($0)" }.joined(separator: ", ")
    }
}

// MARK: - CustomDebugStringConvertible
extension KeyData: CustomDebugStringConvertible {}
public extension KeyData {
    public var debugDescription: String {
        return "Decimal: `\(description)`\nHex: `\(arrayOfHexAsString)`"
    }
}

// MARK: - Comparable
extension KeyData: Comparable {}
public extension KeyData {

    static func < (lhs: KeyData, rhs: KeyData) -> Bool {
        return compare(lhs, with: rhs) {
            for pair in (zip($0, $1).map { ($0, $1) }) {
                if pair.0 < pair.1 { return true }
            }
            return false
        }
    }

    static func > (lhs: KeyData, rhs: KeyData) -> Bool {
        return compare(lhs, with: rhs) {
            for pair in (zip($0, $1).map { ($0, $1) }) {
                if pair.0 > pair.1 { return true }
            }
            return false
        }
    }

    static func == (lhs: KeyData, rhs: KeyData) -> Bool {
        return compare(lhs, with: rhs) {
            zip($0, $1).map { ($0, $1) }.map { $0 == $1 }.and
        }
    }
}

// MARK: - Public Extensin
public extension KeyData {

    var length: Int { return elements.count }

    var arrayOfHexAsString: String {
        return elements.map { String(format: "%02X", $0) }.joined(separator: ", ")
    }
}

// MARK: Private
private extension KeyData {
    mutating func prepend(_ element: Element) {
        elements.insert(element, at: 0)
    }

    private static func appendLeadingZerosUntilLengthOf(_ lhs: KeyData, equalsLengthOf rhs: KeyData) -> (lhs: KeyData, rhs: KeyData) {
        var lhs = lhs
        var rhs = rhs
        while lhs.length != rhs.length {
            if lhs.length > rhs.length {
                rhs.prepend(0)
            } else {
                lhs.prepend(0)
            }
        }
        return (lhs: lhs, rhs: rhs)
    }

    private static func compare(_ lhs: KeyData, with rhs: KeyData, compareElements: (KeyData, KeyData) -> Bool) -> Bool {
        let pair = appendLeadingZerosUntilLengthOf(lhs, equalsLengthOf: rhs)
        return compareElements(pair.lhs, pair.rhs)
    }
}

