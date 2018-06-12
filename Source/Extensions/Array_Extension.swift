//
//  Array_Extension.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-05.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

extension Array where Element: BinaryInteger {

//    func droppingTrailingZeros() -> [Element] {
//        var elements = self
//        elements.dropTrailingZeros()
//        return elements
//    }
//
//    mutating func dropTrailingZeros() {
//        while last == 0 {
//            removeLast()
//        }
//    }

    func droppingLeadingZeros() -> [Element] {
        var elements = self
        elements.dropLeadingZeros()
        return elements
    }

    mutating func dropLeadingZeros() {
        while first == 0 {
            removeFirst()
        }
    }
}
