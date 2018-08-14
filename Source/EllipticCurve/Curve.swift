//
//  Curve.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-08-02.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol PrivateKeyConvertible {}
public protocol PublicKeyConvertible {}

public protocol KeyExchange {}

public protocol DiffieHellman: KeyExchange {
    func diffieHellman(alice: PrivateKeyConvertible, bob: PublicKeyConvertible) -> PublicKeyConvertible
}

public enum SpecificCurve: Equatable {
    case curve25519, secp256r1, secp256k1
    case custom(String)
}

public protocol OverGaloisField {
    var galoisField: Field { get }
}

public protocol CurveParameterExpressible: OverGaloisField {
    var order: Number { get }
    var curveId: SpecificCurve { get }

    var generator: TwoDimensionalPoint { get }
    var cofactor: Number { get }
}

public protocol Curve: CurveParameterExpressible {
    associatedtype EquationType: Equation
    var equation: EquationType { get }
    func contains<P>(point: P) -> Bool where P: Point
    func isIdentity<P>(point: P) -> Bool where P: Point
    func generatePrivateKey() -> Number
    func generatePrivateKey(modify: (Number) -> Number) -> Number
    static func *(number: Number, curve: Self) -> AffinePointOnCurve<Self>
}


public extension Curve {
    static func *(curve: Self, number: Number) -> AffinePointOnCurve<Self> {
        return number * curve
    }

    static func *(number: Number, curve: Self) -> AffinePointOnCurve<Self> {
        fatalError()
    }

}

public func decodeScalar25519(_ number: Number) -> Number {
    var bytes32 = number.as256bitLongData().bytes
    bytes32[0] &= Byte(248)
    bytes32[31] &= Byte(127)
    bytes32[31] |= Byte(64)
    return Number(data: Data(bytes32))
}

public extension Curve {
    func contains<P>(point: P) -> Bool where P: Point {
        if isIdentity(point: point) {
            return true
        } else {
            return equation.isZero(point: point)
        }
    }

    func containsPointAt(x: Number, y: Number) -> Bool {
        return contains(point: AffinePointOnCurve<Self>(x: x, y: y))
    }

    func generatePrivateKey() -> Number {
        precondition(curveId == .curve25519, "Curve25519 requires some special operations")
        let restrictions: (Number) -> Number
        if curveId == .curve25519 {
            restrictions = { decodeScalar25519($0) }
        } else {
            restrictions = { $0 }
        }
        return generatePrivateKey(modify: restrictions)
    }

    func generatePrivateKey(modify: (Number) -> Number) -> Number {
        let byteCount = (order - 1).as256bitLongData().bytes.count
        var privateKey: Number!
        while privateKey == nil {
            guard let randomBytes = try? securelyRandomizeBytes(count: byteCount) else { continue }
            privateKey = Number(data: Data(bytes: randomBytes))
        }
        return modify(privateKey)
    }
}



public extension Curve {

    func mod(_ number: Number) -> Number {
        return galoisField.mod(number)
    }

    func mod(expression: @escaping () -> Number) -> Number {
        return galoisField.mod(expression: expression)
    }

    func modInverseP(_ v: Number, _ w: Number) -> Number {
        return galoisField.modInverse(v, w)
    }

    func modInverseN(_ v: Number, _ w: Number) -> Number {
        return divide(v, by: w, mod: order)
    }
}
