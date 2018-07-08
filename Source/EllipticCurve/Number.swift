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

    func isOdd() -> Bool {
        func _isOdd(_ number: Number) -> Bool {
            return number.magnitude[bitAt: 0]
        }

        assert(_isOdd(1))
        assert(!_isOdd(2))
        assert(_isOdd(3))
        assert(!_isOdd(4))
        return _isOdd(self)
    }

    func asHexStringLength64(uppercased: Bool = true) -> String {
        var hexString = toString(uppercased: uppercased, radix: 16)
        while hexString.count < 64 {
            hexString = "0\(hexString)"
        }
        return hexString
    }
}

public func pow(_ base: Number, _ exponent: Number, _ modulus: Number) -> Number {
    return base.power(exponent, modulus: modulus)
}
