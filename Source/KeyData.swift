//
//  KeyData.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-05.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol KeyData: Comparable, Collection, ExpressibleByArrayLiteral, CustomStringConvertible, CustomDebugStringConvertible where Element == UInt64, Index == Int {

    var elements: [Element] { get }
    init(leastSignigicantElementLeading elements: [Element])
    init(_ mostSignigicantElementLeading: [Element])
    init(hexString: String) throws
}

public extension KeyData {
    public init(_ mostSignigicantElementLeading: [Element]) {
        self.init(leastSignigicantElementLeading: mostSignigicantElementLeading.reversed())
    }
}

public extension KeyData {
    public init(arrayLiteral elements: Element...) {
        let mostSignigicantElementLeading = elements
        self.init(mostSignigicantElementLeading)
    }
}

// MARK: - Collection
public extension KeyData {

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

// MARK: - Convenience Init
public extension KeyData {

    init(hexString: String) throws {
        guard hexString.containsOnlyHexChars() else { throw KeyDataError.stringInvalidChars }
        let string = hexString.droppingTwoLeadinHexCharsIfNeeded()
        let arrayOfHex = try string.splittingIntoSubStringsOfLength(2) // 16^2 = 256 bits
        let mostSignigicantElementLeading = arrayOfHex.compactMap { Element($0, radix: 16) }
        guard arrayOfHex.count == mostSignigicantElementLeading.count else { fatalError("Incorrect implementation, case should be handled above") }
        self.init(mostSignigicantElementLeading)
    }
}

// MARK: - Public Extension
public extension KeyData {

    var length: Int { return elements.count }
    var isEmpty: Bool { return length == 0 }

    func asHexString(uppercased: Bool = true, separator: String = "", trimLeadingZeros: Bool = false) -> String {
        guard !isEmpty else { return "" }

        var trimLeadingZeros = trimLeadingZeros

        if length > 1 {
            // When length is greater than 1:
            // Allow trimming of leading zeros iff separator != ""
            // Given the assumption that string method trimming leading zeros never changes the string "0" into the empty string "":
            // Otherwise the following dangerous scenario could happen:
            // let data = `[1, 0, 1]`
            // data.asHexString(separator: ", ") => `"0000000000000001, 0000000000000000, 0000000000000001"`
            // So far so good. Since the hexString representation of the data splits each element with separator ', ' it is safe to trim leading zeros, since their bit position can be drived using the comma:
            // data.asHexString(separator: ", ", trimLeadingZeros: true) => `"1, 0, 1"`
            // But imagine we pass the empty string as separator (default arg) and allow trimming of leading zeros, then we would lose data!
            // data.asHexString(separator: "", trimLeadingZeros: true) => `"101"`
            // `"101"` string representation of `[1, 0, 1]` cannot be destinguised from `[101]` or `[10, 1]`

            trimLeadingZeros = !separator.isEmpty && trimLeadingZeros
        }

        func trimmingIfNeeded(_ string: String) -> String {
            guard trimLeadingZeros else { return string }
            return string.droppingLeadingZerosIfNeeded()
        }

        let bits = "\(elementHexCharacterCount)"
        let hex = uppercased ? "X" : "x"
        let format = "%0" + bits + hex // e.g. "%016X"

        var numbers: [Element] = elements.reversed()
        if trimLeadingZeros {
            numbers.dropLeadingZerosIfNonAllZeroOrEmpty()
        }

        return numbers.map { trimmingIfNeeded(String(format: format, $0)) }.joined(separator: separator)
    }

    var arrayOfHexAsString: String {
        let csv = asHexString(separator: ", ")
        return "[\(csv)]"
    }
}



// MARK: - CustomStringConvertible
public extension KeyData {
    public var description: String {
        let csv = elements.map { "\($0)" }.joined(separator: ", ")
        return "[\(csv)]"
    }
}

// MARK: - CustomDebugStringConvertible
public extension KeyData {
    public var debugDescription: String {
        return "Decimal: `\(description)`\nHex: `\(arrayOfHexAsString)`"
    }
}

// MARK: - Comparable
public extension KeyData {

    static func < (lhs: Self, rhs: Self) -> Bool {
        return compare(lhs, with: rhs) {
            for pair in (zip($0, $1).map { ($0, $1) }) {
                if pair.0 < pair.1 { return true }
            }
            return false
        }
    }

    static func > (lhs: Self, rhs: Self) -> Bool {
        return compare(lhs, with: rhs) {
            for pair in (zip($0, $1).map { ($0, $1) }) {
                if pair.0 > pair.1 { return true }
            }
            return false
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return compare(lhs, with: rhs) {
            zip($0, $1).map { ($0, $1) }.map { $0 == $1 }.and
        }
    }
}

public extension Array {
    func appending(_ element: Element) -> [Element] {
        var elements = self
        elements.append(element)
        return elements
    }
}

// MARK: Private
private extension KeyData {
    private static func appendLeadingZerosUntilLengthOf(_ lhs: Self, equalsLengthOf rhs: Self) -> (lhs: Self, rhs: Self) {
        var lhs = lhs
        var rhs = rhs
        while lhs.length != rhs.length {
            func appending(_ element: Element, to keyData: Self) -> Self {
                return Self(leastSignigicantElementLeading: keyData.elements.appending(element))
            }
            if lhs.length > rhs.length {
                rhs = appending(0, to: rhs)
            } else {
                lhs = appending(0, to: lhs)
            }
        }

        return (lhs: lhs, rhs: rhs)
    }

    private static func compare(_ lhs: Self, with rhs: Self, compareElements: (Self, Self) -> Bool) -> Bool {
        let pair = appendLeadingZerosUntilLengthOf(lhs, equalsLengthOf: rhs)
        return compareElements(pair.lhs, pair.rhs)
    }
}

public extension KeyData {
    static var elementBitWidth: Int {
        return Element.bitWidth
    }

    static var bitsPerHex: Int {
        return 4 // 16 = 2^4
    }

    static var elementHexCharacterCount: Int {
        return elementBitWidth / bitsPerHex
    }
}

public extension KeyData {
    var elementBitWidth: Int {
        return Self.elementBitWidth
    }

    var bitsPerHex: Int {
        return Self.bitsPerHex
    }

    var elementHexCharacterCount: Int {
        return Self.elementHexCharacterCount
    }
}
