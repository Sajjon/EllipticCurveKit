//
//  KeyDataStruct.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-08.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import BigInt

public typealias KeyData = BigUInt

extension BigUInt: KeyDataConvertible {}
public extension BigUInt {

    init(lsbZeroIndexed words: [Word]) {
        self.init(words: words)
    }

    init?(msbZeroIndexed string: String, radix: Int) {
        let string = radix == 16 ? string.droppingTwoLeadinHexCharsIfNeeded() : string
        self.init(string, radix: radix)
    }
}
