//
//  Number.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-06.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import EquationKit
import BigInt

public func ^^(lhs: Int, rhs: Int) -> Number {
    return Number(lhs).power(rhs)
}
public func -(lhs: BigInt, rhs: Int) -> BigInt {
    return lhs - BigInt(rhs)
}
public func +(lhs: BigInt, rhs: Int) -> BigInt {
    return lhs + BigInt(rhs)
}


public typealias Number = BigInt

public extension Number {

    public init(sign: Number.Sign = .plus, _ words: [Number.Word]) {
        let magnitude = Number.Magnitude(words: words)
        self.init(sign: sign, magnitude: magnitude)
    }

    public init(sign: Number.Sign = .plus, data: Data) {
        self.init(sign: sign, Number.Magnitude(data))
    }

    public init(sign: Number.Sign = .plus, _ magnitude: Number.Magnitude) {
        self.init(sign: sign, magnitude: magnitude)
    }

    public init?(hexString: String) {
        var hexString = hexString
        if hexString.starts(with: "0x") {
            hexString = String(hexString.dropFirst(2))
        }
        self.init(hexString, radix: 16)
    }

    public init?(decimalString: String) {
        self.init(decimalString, radix: 10)
    }

    var isEven: Bool {
        guard self.sign == .plus else { fatalError("what to do when negative?") }
        return magnitude[bitAt: 0] == false
    }

    func asHexString(uppercased: Bool = true) -> String {
        return toString(uppercased: uppercased, radix: 16)
    }

    func asDecimalString() -> String {
        return toString(radix: 10)
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

    func as256bitLongData() -> Data {
        return Data(hex: asHexStringLength64())
    }

    func asTrimmedData() -> Data {
        return self.magnitude.serialize()
    }
}

extension Number {
    /// Override ExpressibleByStringLiteral default init in BigInt, by accepting hexadecimal string instead of decimal
    public init(stringLiteral value: StringLiteralType) {
        self.init(hexString: value)!
    }
}

extension Data {
    func toNumber() -> Number {
        return Number(data: self)
    }
}

precedencegroup ExponentiationPrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}

infix operator ** : ExponentiationPrecedence

public func ^ (_ base: Number, _ exponent: Number) -> Number {
    return base ** exponent
}
public func ^ (_ base: Number, _ exponent: Int) -> Number {
    return base ** exponent
}

public func ** (_ base: Number, _ exponent: Number) -> Number {
    guard exponent.bitWidth < 32 else { fatalError("exponent too big") }
    let decimalString = exponent.asDecimalString()
    let intExponent = Int(decimalString)!
    return base ** intExponent
}

public func ** (_ base: Number, _ exponent: Int) -> Number {
    return base.power(exponent)
}
