//
//  AffinePoint.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation


public struct AffinePoint<CurveType: EllipticCurve>: EllipticCurvePoint {
    public typealias Curve = CurveType
    public let x: Number
    public let y: Number

    public init(x: Number, y: Number) {
        self.x = x
        self.y = y
    }
}

public func * <C>(scalar: Number, affinePoint: AffinePoint<C>) -> AffinePoint<C> {
    affinePoint * scalar
}

public func * <C>(privateKey: PrivateKey<C>, publicKey: PublicKey<C>) -> AffinePoint<C> {
    privateKey.number * publicKey.point
}


public func + <C>(point: AffinePoint<C>, publicKey: PublicKey<C>) -> AffinePoint<C> {
    AffinePoint<C>.addPoint(point, to: publicKey.point)
}

public func + <C>(publicKey: PublicKey<C>, point: AffinePoint<C>) -> AffinePoint<C> {
    point + publicKey
}

extension Number {
    func negated() -> Self {
        var copy = self
        copy.negate()
        return copy
    }
}

public extension AffinePoint {
    
    enum Error: Swift.Error {
        case incorrectByteCountOfPublicKey(expectedByteCount: Int, butGot: Int)
        case failedToSerializeBytes
    }
    
    init(hex: String) throws {
        try self.init(data: Data(hex: hex))
    }
    
    
    init(data: Data) throws {
        if data.count == 33 {
            self = try Self.decodeFromCompressedPublicKey(bytes: data)
        } else if data.count == 65 {
            self = try Self.decodeFromUncompressedPublicKey(bytes: data)
        } else {
            throw Error.failedToSerializeBytes
        }
    }
    
    static func decodeFromUncompressedPublicKey(bytes: Data) throws -> Self {
        guard bytes.count == 65 else { throw Error.incorrectByteCountOfPublicKey(expectedByteCount: 65, butGot: bytes.count) }
        precondition(bytes[0] == 0x04)
        return Self(
            x: .init(bytes.subdata(in: 1..<33)),
            y: .init(bytes.subdata(in: 33..<65))
        )
    }
    
    static func decodeFromCompressedPublicKey(bytes: Data) throws -> Self {
        guard bytes.count == 33 else { throw Error.incorrectByteCountOfPublicKey(expectedByteCount: 33, butGot: bytes.count) }
        let isOdd = bytes[0] == 0x03
        return decodeFromX(
            x: .init(bytes.suffix(32)),
            isOdd: isOdd
        )
    }
    
    static func decodeFromX(x: Number, isOdd: Bool) -> Self {
        let P = Curve.P
        let a = Curve.a
        let b = Curve.b
        
        //  y² = x³ + ax + b
        let x3 = x.power(3, modulus: P)
        let y2 = modP { x3 + a*x + b }
        
        guard
            let squareRootsOfY = squareRoots(of: y2, modulus: P)
        else {
            fatalError("Expected to always be able to calc square roots of Y")
        }
        
        guard let firstSquareRootOfY = squareRootsOfY.first else {
            fatalError("Expected to always be able to get one root of Y")
            
        }
        
        let y: Number
        if isOdd {
            y = (firstSquareRootOfY.modulus(2) == 1 ? firstSquareRootOfY : firstSquareRootOfY.negated()).modulus(P)
        } else {
            y = (firstSquareRootOfY.modulus(2) == 0 ? firstSquareRootOfY : firstSquareRootOfY.negated()).modulus(P)
        }
        return .init(x: x, y: y)
    }

    /// From: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki#specification
    /// "Addition of points refers to the usual elliptic curve group operation."
    /// reference: https://en.wikipedia.org/wiki/Elliptic_curve#The_group_law
    static func addition(_ p1: Self?, _ p2: Self?) -> Self? {
        return addition_v2(p1, p2)
    }

    static func addition_v1(_ p1: Self?, _ p2: Self?) -> Self? {
        guard let p1 = p1 else { return p2 }
        guard let p2 = p2 else { return p1 }

        if p1.x == p2.x && p1.y != p2.y {
            return nil
        }

        let P = Curve.P

        let λ = modP {
            if p1 == p2 {
                return (3 * (p1.x * p1.x) + Curve.a) * (2 * p1.y).power(P - 2, modulus: P)
            } else {
                return (p2.y - p1.y) * (p2.x - p1.x).power(P - 2, modulus: P)
            }
        }
        let x3 = modP { λ * λ - p1.x - p2.x }
        let y3 =  modP { λ * (p1.x - x3) - p1.y }

        return Self(x: x3, y: y3)
    }

    static func addition_v2(_ p1: Self?, _ p2: Self?) -> Self? {
        guard let p1 = p1 else { return p2 }
        guard let p2 = p2 else { return p1 }

        if p1.x == p2.x && p1.y != p2.y {
            return nil
        }

        if p1 == p2 {
            /// or `p2`, irrelevant since they equal each other
            return doublePoint(p1)
        } else {
            return addPoint(p1, to: p2)
        }
    }

    fileprivate static func addPoint(_ p1: Self, to p2: Self) -> Self {
        precondition(p1 != p2)
        let λ = modInverseP(p2.y - p1.y, p2.x - p1.x)
        let x3 = modP { λ * λ - p1.x - p2.x }
        let y3 = modP { λ * (p1.x - x3) - p1.y }
        return Self(x: x3, y: y3)
    }

    private static func doublePoint(_ p: Self) -> Self {
        let λ = modInverseP(3 * (p.x * p.x) + Curve.a, 2 * p.y)

        let x3 = modP { λ * λ - 2 * p.x }
        let y3 = modP { λ * (p.x - x3) - p.y }

        return Self(x: x3, y: y3)
    }

    /// From: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki#specification
    /// "Multiplication of an integer and a point refers to the repeated application of the group operation."
    /// reference: https://en.wikipedia.org/wiki/Elliptic_curve_point_multiplication
    static func * (point: Self, number: Number) -> Self {
        var P: Self? = point
        let n = number
        var r: Self!
        for i in 0..<n.magnitude.bitWidth {
            if n.magnitude[bitAt: i] {
                r = addition(r, P)
            }
            P = addition(P, P)
        }
        return r
    }

}
