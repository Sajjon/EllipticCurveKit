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

public extension Number {

    init(sign: Number.Sign = .plus, _ words: [Number.Word]) {
        let magnitude = Number.Magnitude(words: words)
        self.init(sign: sign, magnitude: magnitude)
    }

    init(sign: Number.Sign = .plus, data: Data) {
        let magnitude = Number.Magnitude(data)
        self.init(sign: sign, magnitude: magnitude)
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

    var isOdd: Bool {
        return magnitude[bitAt: 0]
    }

    func asHexString(uppercased: Bool = true) -> String {
        return toString(uppercased: uppercased, radix: 16)
    }

    func asDecimalString(uppercased: Bool = true) -> String {
        return toString(uppercased: uppercased, radix: 10)
    }

    func toString(uppercased: Bool = true, radix: Int) -> String {
        let stringRepresentation = String(self, radix: radix)
        guard uppercased else { return stringRepresentation }
        return stringRepresentation.uppercased()
    }

    func asHexStringLength64(uppercased: Bool = true) -> String {
        var hexString = toString(uppercased: uppercased, radix: 16)
        while hexString.count < 64 {
            hexString = "0\(hexString)"
        }
        return hexString
    }

    func asData() -> Data {
        return magnitude.serialize()
    }
}

public func pow(_ base: Number, _ exponent: Number, _ modulus: Number) -> Number {
    return base.power(exponent, modulus: modulus)
}
