//
//  KeyDataConvertible.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-05.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol KeyDataConvertible: Comparable, Collection, ExpressibleByArrayLiteral, CustomStringConvertible, CustomDebugStringConvertible where Element: FixedWidthInteger & UnsignedInteger & CVarArg, Index == Int {

    var elements: [Element] { get }
    init(lsbZeroIndexed: [Element])
    init(msbZeroIndexed: [Element])
    init(msbZeroIndexed: String) throws
    init(msbZeroIndexed hexString: String, separatedBy separator: Separator?) throws
}

public extension KeyDataConvertible {
    public init(msbZeroIndexed: [Element]) {
        self.init(lsbZeroIndexed: Array(msbZeroIndexed.droppingLeadingZeros().reversed()))
    }
}

// MARK: - ExpressibleByArrayLiteral
public extension KeyDataConvertible {
    public init(arrayLiteral elements: Element...) {
        self.init(msbZeroIndexed: elements)
    }
}

// MARK: - Collection
public extension KeyDataConvertible {

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

public enum Separator: Character {
    case comma = ","
    case space = " "

}

// MARK: - Convenience Init
public extension KeyDataConvertible {

    init(msbZeroIndexed hexStringArray: [String]) throws {
        let msbZeroIndexed = hexStringArray.compactMap { Element($0, radix: 16) }
        guard hexStringArray.count == msbZeroIndexed.count else { throw KeyDataConvertibleError.stringInvalidChars }
        self.init(msbZeroIndexed: msbZeroIndexed)
    }

    init(msbZeroIndexed hexString: String, separatedBy separator: Separator?) throws {
        var hexString = hexString.droppingTwoLeadinHexCharsIfNeeded()

        func splitting(_ string: String) throws -> [String] {

            if let separator = separator {
                guard string.containsOnlyHexChars(or: separator.rawValue) else {  throw KeyDataConvertibleError.separatorMismatch }
                return string.split(separator: separator.rawValue).map { String($0) }
            } else {
                var string = string
                while string.count % Self.bitsPerHex != 0 {
                    string = "0" + string
                }
                // Element.bitWidth: 8
                // 'A4B1CDE5' -> ['A4', 'B1', 'CD', 'E5']
                // Element.bitWidth: 64
                // 'A4B1' -> ['A4B1', 'CDE5']
                return try string.splittingIntoSubStringsOfLength(Self.bitsPerHex)
            }
        }

        let hexStringArray = try splitting(hexString)

        for part in hexStringArray {
            guard part.containsOnlyHexChars() else { throw KeyDataConvertibleError.stringInvalidChars }
        }

        try self.init(msbZeroIndexed: hexStringArray)
    }

    init(msbZeroIndexed hexString: String) throws {
        try self.init(msbZeroIndexed: hexString, separatedBy: nil)
    }
}

public enum HexFormatting {
    case noTrimming(separator: String)
    case trim(nonEmptySeparator: String)

    var separator: String {
        switch self {
        case .noTrimming(let separator): return separator
        case .trim(let separator): return separator
        }
    }

    var shouldTrim: Bool {
        switch self {
        case .noTrimming: return false
        case .trim: return true
        }
    }

    var isValid: Bool {
        switch self {
        case .trim(let separator): return !separator.isEmpty
        case .noTrimming: return true
        }
    }

    var guaranteedValid: HexFormatting {
        guard isValid else { return .default }
        return self
    }

}

public extension HexFormatting {
    static var `default`: HexFormatting {
        let value = HexFormatting.noTrimmingEmptySeparator
        guard value.isValid else { fatalError("default formatting should be valid") }
        return value
    }


    static var noTrimmingEmptySeparator: HexFormatting {
        return .noTrimming(separator: "")
    }
}

// MARK: - Public Extension
public extension KeyDataConvertible {

    var length: Int { return elements.count }
    var isEmpty: Bool { return length == 0 }

    func asHexString(uppercased: Bool = true, formatting: HexFormatting = .default) -> String {
        guard !isEmpty else { return "" }
        let formatting = formatting.guaranteedValid

        func trimmingIfNeeded(_ string: String) -> String {
            guard formatting.shouldTrim else { return string }
            return string.droppingLeadingZerosIfNeeded()
        }

        let bits = "\(elementHexCharacterCount)"
        let hex = uppercased ? "X" : "x"
        let format = "%0" + bits + hex // e.g. "%016X"

        return elements.reversed()
            .map { trimmingIfNeeded(String(format: format, $0)) }
            .joined(separator: formatting.separator)
    }

    var arrayOfHexAsString: String {
        let csv = asHexString(formatting: .trim(nonEmptySeparator: ", "))
        return "[\(csv)]"
    }
}



// MARK: - CustomStringConvertible
public extension KeyDataConvertible {
    public var description: String {
        let csv = elements.map { "\($0)" }.joined(separator: ", ")
        return "[\(csv)]"
    }
}

// MARK: - CustomDebugStringConvertible
public extension KeyDataConvertible {
    public var debugDescription: String {
        return "Decimal: `\(description)`\nHex: `\(arrayOfHexAsString)`"
    }
}

// MARK: - Comparable
public extension KeyDataConvertible {

    /// Compare `a` to `b` and return an `NSComparisonResult` indicating their order.
    ///
    /// - Complexity: O(count)
    static func compare(_ a: Self, _ b: Self) -> ComparisonResult {
        if a.count != b.count { return a.count > b.count ? .orderedDescending : .orderedAscending }
        for i in (0 ..< a.count) {
            let ad = a[i]
            let bd = b[i]
            if ad != bd { return ad > bd ? .orderedDescending : .orderedAscending }
        }
        return .orderedSame
    }

    /// Return true iff `a` is equal to `b`.
    ///
    /// - Complexity: O(count)
    static func ==(a: Self, b: Self) -> Bool {
        return Self.compare(a, b) == .orderedSame
    }

    /// Return true iff `a` is less than `b`.
    ///
    /// - Complexity: O(count)
    static func <(a: Self, b: Self) -> Bool {
        return Self.compare(a, b) == .orderedAscending
    }
}

public extension KeyDataConvertible {
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

public extension KeyDataConvertible {
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
