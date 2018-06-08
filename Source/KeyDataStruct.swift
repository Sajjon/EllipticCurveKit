//
//  KeyDataStruct.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-08.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct KeyDataStruct: KeyData {
    public typealias Element = UInt64

    // Least significant element at index 0
    public private(set) var elements: [Element]

    public init(leastSignigicantElementLeading elements: [Element]) {
        self.elements = elements
    }
}

//import BigInt
//extension BigUInt: KeyData {
//    var elements: [Element] { return words }
//}
