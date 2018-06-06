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

    public init(leastSignigicantElementLeading elements: [Element]) {
        self.elements = elements
    }

    public enum Error: Int, Swift.Error {
        case stringInvalidChars, stringLengthNotEven
    }
}

// MARK: - Convenience Init
public extension KeyData {

    public init(_ elements: [Element]) {
        self.init(leastSignigicantElementLeading: elements.reversed())
    }

    init(hexString: String) throws {
        guard hexString.containsOnlyHexChars() else { throw Error.stringInvalidChars }
        let string = hexString.dropTwoLeadinHexCharsIfNeeded()
        let arrayOfHex = try string.splitIntoSubStringsOfLength(2) // 16^2 = 256 bits
        let array = arrayOfHex.compactMap { Element($0, radix: 16) }
        guard arrayOfHex.count == array.count else { fatalError("Incorrect implementation, case should be handled above") }
        self.init(array)
    }
}

// MARK: - ExpressibleByArrayLiteral
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
        let csv = elements.map { "\($0)" }.joined(separator: ", ")
        return "[\(csv)]"
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

    func asHexString(uppercased: Bool = true, separator: String = "") -> String {
        let format = uppercased ? "%02X" : "%02x"
        return elements.reversed().map { String(format: format, $0) }.joined(separator: separator)
    }

    var arrayOfHexAsString: String {
        let csv = asHexString(separator: ", ")
        return "[\(csv)]"
    }
}

// MARK: Private
private extension KeyData {
    mutating func append(_ element: Element) {
        elements.append(element)
    }

    private static func appendLeadingZerosUntilLengthOf(_ lhs: KeyData, equalsLengthOf rhs: KeyData) -> (lhs: KeyData, rhs: KeyData) {
        var lhs = lhs
        var rhs = rhs
        while lhs.length != rhs.length {
            if lhs.length > rhs.length {
                rhs.append(0)
            } else {
                lhs.append(0)
            }
        }
        return (lhs: lhs, rhs: rhs)
    }

    private static func compare(_ lhs: KeyData, with rhs: KeyData, compareElements: (KeyData, KeyData) -> Bool) -> Bool {
        let pair = appendLeadingZerosUntilLengthOf(lhs, equalsLengthOf: rhs)
        return compareElements(pair.lhs, pair.rhs)
    }
}

