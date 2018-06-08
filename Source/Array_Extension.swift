//
//  Array_Extension.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-05.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

extension Array where Element == Bool {
    var and: Bool {
        return !contains(false)
    }
}

extension Array where Element: BinaryInteger {

    func indexOfFirstNonZeroElement() -> Index? {
        for (index, element) in self.enumerated() {
            guard element > 0 else { continue }
            return index
        }
        return nil
    }

    func droppingLeadingZerosIfNonAllZeroOrEmpty() -> [Element] {
        guard let index = indexOfFirstNonZeroElement() else { return self }
        return Array(self[index..<endIndex])
    }

    mutating func dropLeadingZerosIfNonAllZeroOrEmpty() {
        self = droppingLeadingZerosIfNonAllZeroOrEmpty()
    }
}
