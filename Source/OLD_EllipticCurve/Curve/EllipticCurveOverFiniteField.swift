//
//  EllipticCurveOverFiniteField.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-07.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//


import Foundation
import BigInt

public protocol EllipticCurveOverFiniteField: Equatable {
    // `z` == `isInifinity`, has either value `0` or `1`, nothing else
    var G: (x: Number, y: Number, z: Number) { get set }
    var a: Number { get }
    var b: Number { get }
    var P: Number { get }
    var N: Number { get }
    init(G: (x: Number, y: Number, z: Number), a: Number, b: Number, P: Number, N: Number)
    init<C>(curve: C) where C: EllipticCurveOverFiniteField
}

public extension EllipticCurveOverFiniteField {
    var order: Number {
        return N
    }
}

public extension EllipticCurveOverFiniteField {
    init(G: (x: Number, y: Number, z: Number), a: Number, b: Number, P: Number) {
        self.init(G: G, a: a, b: b, P: P, N: 0)
    }

    init(a: Number, b: Number, P: Number) {
        self.init(G: (x: 0, y: 0, z: 0), a: a, b: b, P: P)
    }

    init<C>(curve: C) where C: EllipticCurveOverFiniteField {
        self.init(G: curve.G, a: curve.a, b: curve.b, P: curve.P, N: curve.N)
    }
}


public extension EllipticCurveOverFiniteField {
    /// Transform projective coordinates of self to the usual (x, y) coordinates.
    /// https://www.duo.uio.no/bitstream/handle/10852/56868/masterOlavWegnerEide.pdf
    /// page 18 (under `Defintion 2.13`):
    ///
    /// Because the projective coordinates represent lines and not points, the notation (x : y : z) is commonly used, although they are still referred to as points.
    /// To go from affine coordinates (x, y) to projective coordinates (x : y : z), let z = 1 so that (x, y) → (x : y : 1). Equivalently, projective coordinates can be translated to affine coordinates: (x : y : 1) → (x, y). These points are the finite points in the projective plane. In the cases where z ̸= 1 and z ̸= 0, the projective point can be normalized by dividingbyz: (x:y:z)=(x/z:y/z:1). Notethattheinverseofzwillexistforall nonzero z ∈ Fq. The projective points (x : y : 0) are called the points at infinity. These points map to the affine point ∞. In this way, the point at infinity(∞) have clearly been defined as a point in the projective plane
    ///
    /// CODE EXAMPLES, see:
    /// JAVA:
    /// nayuki: https://github.com/nayuki/Bitcoin-Cryptography-Library/blob/master/java/io/nayuki/bitcoin/crypto/CurvePointMath.java
    ///
    /// PYTHON:
    /// nayuki: https://www.nayuki.io/res/elliptic-curve-point-addition-in-projective-coordinates/ellipticcurve.py
    ///
    /// - Returns: return normalized coordinates
    func normalized() -> Self {
        fatalError()
    }

}

public extension EllipticCurveOverFiniteField {
    /// Computes self cross product with x and check if the result is 0.
    static func == (lhs: Self, rhs: Self) -> Bool {
        let `self` = lhs

        return self.G.x * rhs.G.y == self.G.y * rhs.G.x &&
            self.G.y * rhs.G.z == self.G.z * rhs.G.y &&
            self.G.z * rhs.G.x == self.G.x * rhs.G.z &&
            self.a == rhs.a &&
            self.b == rhs.b &&
            self.P == rhs.P

    }

    static func + (lhs: Self, rhs: Self) -> Self {
        fatalError()
    }

    static func * (lhs: Self, rhs: Number) -> Self {
        fatalError()
    }
}

public func pow(_ base: Number, _ exponent: Number, _ modulus: Number) -> Number {
    return base.power(exponent, modulus: modulus)
}


public struct AnyEllipticCurveOverFiniteField: EllipticCurveOverFiniteField {

    public var G: (x: Number, y: Number, z: Number)
    public let a: Number
    public let b: Number
    public let P: Number
    public let N: Number

    public init(G: (x: Number, y: Number, z: Number) = (x: 0, y: 0, z: 0), a: Number, b: Number, P: Number, N: Number = 0) {
        self.G = G
        self.a = a
        self.b = b
        self.P = P
        self.N = N
    }
}

public extension AnyEllipticCurveOverFiniteField {
    static var secp256k1: AnyEllipticCurveOverFiniteField {
        return AnyEllipticCurveOverFiniteField(
            G: (
                x: Number([0x79BE667EF9DCBBAC, 0x55A06295CE870B07, 0x029BFCDB2DCE28D9, 0x59F2815B16F81798]),
                y: Number([0x483ADA7726A3C465, 0x5DA4FBFC0E1108A8, 0xFD17B448A6855419, 0x9C47D08FFB10D4B8]),
                z: Number(0)
            ),
            a: Number(0),
            b: Number(7),
            P: Number([0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFEFFFFFC2F]),
            N: Number([0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFE, 0xBAAEDCE6AF48A03B, 0xBFD25E8CD0364141])
        )
    }
}

public extension Data {
    var bytes: [UInt8] {
        return [UInt8](self)
    }
}

public extension Array where Element == UInt8 {
    var data: Data {
        return Data(bytes: self)
    }
}

public func toByteArrary<T>(value: T)  -> [Byte] where T: UnsignedInteger & FixedWidthInteger {
    var bigEndian = value.bigEndian
    let count = MemoryLayout<T>.size
    let bytePtr = withUnsafePointer(to: &bigEndian) {
        $0.withMemoryRebound(to: Byte.self, capacity: count) {
            UnsafeBufferPointer(start: $0, count: count)
        }
    }

    return Array(bytePtr)
}

public func uint64ArrayToByteArray(_ uint64Array: [UInt64]) -> [Byte] {
    return uint64Array.flatMap { toByteArrary(value: $0) }
}

public extension Number {

    //    func asUInt64Array() -> (array: [UInt64], sign: Number.Sign) {
    //        var array = [UInt64]()
    //        for i in 0..<words.count {
    //            let uint = UInt64(words[i])
    //            array.append(uint)
    //        }
    //        return (array: array, sign: self.sign)
    //    }
    //
    //    func toBitArray() -> (bits: [Bit], sign: Number.Sign) {
    //        let (uint64Array, _) = asUInt64Array()
    //        let byteArray = uint64ArrayToByteArray(uint64Array)
    //        let bits = bytesToBits(bytes: byteArray)
    //        return (bits: bits, sign: self.sign)
    //    }

    func toBitArray() -> (bits: [Bit], sign: Number.Sign) {
        var bits = [Bit]()
        for bitIndex in 0..<bitWidth {
            bits.append(self.magnitude[bitAt: bitIndex])
        }
        return (bits: bits, sign: self.sign)
    }

    public init(sign: Number.Sign, bitArray: [Bit]) {
        let byteArray = bitsToBytes(bits: bitArray)
        let data = Data(bytes: byteArray)
        let unsigned = Number.Magnitude(data)
        self.init(sign: sign, magnitude: unsigned)
    }
}
