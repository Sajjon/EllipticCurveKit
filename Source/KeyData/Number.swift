//
//  Number.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-06.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import BigInt

public typealias Number = BigInt

public extension BigInt {

    init(_ words: [Number.Word]) {
        self.init(sign: .plus, magnitude: BigUInt(words: words))
    }

    init?(hexString: String) {
        var hexString = hexString
        if hexString.starts(with: "0x") {
            hexString = String(hexString.dropFirst(2))
        }
        self.init(hexString, radix: 16)
    }

    init?(decimalString: String) {
        self.init(decimalString, radix: 10)
    }
}
