//
//  String_Extension.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-05.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

extension String {

    func droppingTwoLeadinHexCharsIfNeeded() -> String {
        guard starts(with: "0x") else { return self }
        return String(dropFirst(2))
    }

    func droppingLeadingZerosIfNeeded() -> String {
        return droppingAllLeading(character: "0")
    }

    func droppingAllLeading(character: Character) -> String {
        var string = self
        while string.count > 1 && string.first == character {
            string = String(string.dropFirst())
        }
        return string
    }

    func splittingIntoSubStringsOfLength(_ length: Int) throws -> [String] {
        guard count % length == 0 else { throw KeyDataError.stringLengthNotEven }
        var startIndex = self.startIndex
        var results = [Substring]()

        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(self[startIndex..<endIndex])
            startIndex = endIndex
        }

        return results.map { String($0) }
    }

    func containsOnlyHexChars() -> Bool {
        let string = droppingTwoLeadinHexCharsIfNeeded()
        do {
            let regex = try NSRegularExpression(pattern: "([a-f0-9A-F]){1}")
            let numberOfMatches = regex.numberOfMatches(in: string, range: NSRange(location: 0, length: string.count))
            let containsOnlyHex = numberOfMatches == string.count
            print("numberOfMatches: `\(numberOfMatches)`, containsOnlyHex: `\(containsOnlyHex)`, ")
            return containsOnlyHex
        } catch {
            fatalError("Incorrect implementation of regexp, error: `\(error)`, please fix this.")
        }
    }
}

// MARK: - Mutating
extension String {
    mutating func dropTwoLeadinHexCharsIfNeeded() {
        self = droppingTwoLeadinHexCharsIfNeeded()
    }

    mutating func dropLeadingZerosIfNeeded() {
        self = droppingLeadingZerosIfNeeded()
    }
}
