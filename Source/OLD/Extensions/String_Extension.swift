//
//  String_Extension.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-05.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public extension String {

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

//    func splittingIntoSubStringsOfLength(_ length: Int) throws -> [String] {
//        guard count % length == 0 else { throw KeyDataConvertibleError.invalidLength }
//        var startIndex = self.startIndex
//        var results = [Substring]()
//
//        while startIndex < self.endIndex {
//            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
//            results.append(self[startIndex..<endIndex])
//            startIndex = endIndex
//        }
//
//        return results.map { String($0) }
//    }

//    func containsOnlyHexChars(or character: Character) -> Bool {
//        let string = droppingTwoLeadinHexCharsIfNeeded()
//        let numberOfMatchesForCharacter = string.filter { $0 == character }.count
//        let countFromCustomCharacter: Int = String(character).containsOnlyHexChars() ? 0 : numberOfMatchesForCharacter
//        let countOfValidStrings = string.countHexChars() + countFromCustomCharacter
//        return countOfValidStrings == string.count
//    }
//
//    func containsOnlyHexChars() -> Bool {
//        let string = droppingTwoLeadinHexCharsIfNeeded()
//        return string.countHexChars() == string.count
//    }
//
//    func containsNoHexChars() -> Bool {
//        let string = droppingTwoLeadinHexCharsIfNeeded()
//        return string.countHexChars() == 0
//    }
//
//    func countHexChars() -> Int {
//        do {
//            let regex = try NSRegularExpression(pattern: "([a-f0-9A-F]){1}")
//            return regex.numberOfMatches(in: self, range: NSRange(location: 0, length: count))
//        } catch {
//            fatalError("Incorrect implementation of regexp, error: `\(error)`, please fix this.")
//        }
//    }
}

// MARK: - Mutating
public extension String {
    mutating func dropTwoLeadinHexCharsIfNeeded() {
        self = droppingTwoLeadinHexCharsIfNeeded()
    }

    mutating func dropLeadingZerosIfNeeded() {
        self = droppingLeadingZerosIfNeeded()
    }
}
