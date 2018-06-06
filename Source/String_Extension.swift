//
//  String_Extension.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-05.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

extension String {

    func dropTwoLeadinHexCharsIfNeeded() -> String {
        guard starts(with: "0x") else { return self }
        return String(dropFirst(2))
    }

    func splitIntoSubStringsOfLength(_ length: Int) throws -> [String] {
        guard count % length == 0 else { throw KeyData.Error.stringLengthNotEven }
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
        let string = dropTwoLeadinHexCharsIfNeeded()
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
