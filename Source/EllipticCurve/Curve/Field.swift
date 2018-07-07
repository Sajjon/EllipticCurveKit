//
//  Field.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-15.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import BigInt

// Thanks to certicom for tutorials about Elliptic Curve Cryptograph
// https://www.certicom.com/content/certicom/en/ecc.html
// https://www.certicom.com/content/certicom/en/ecc-tutorial.html

public struct Field {
    let prime: Prime
    let a: Number
    let b: Number
    public init(prime: Prime, a: Number, b: Number) {
        self.prime = prime
        self.a = a
        self.b = b
    }
}


/// Elliptic Curve over the field of integers modulo a prime
/// The curve of points satisfying y^2 = x^3 + a*x + b (mod p).
public struct EllipticCurve {


    //    private let p: Number
    //    private let a: Number
    //    private let b: Number
    //
    //    public init(name: String, field: Field, prime p: Number, a: Number, b: Number) {
    //        self.p = p
    //        self.a = a
    //        self.b = b
    //    }
}


public typealias Coordinate = Number
public struct Point {
    public let x: Coordinate
    public let y: Coordinate
    public let isInfinity: Bool
    public init(x: Coordinate, y: Coordinate, isInfinity: Bool = false) {
        self.x = x
        self.y = y
        self.isInfinity = isInfinity
    }
}


public struct PointOnEllipticCurve {

    private let curve: EllipticCurve
    private let point: Point

    public init(curve: EllipticCurve, point: Point) {
        self.curve = curve
        self.point = point
    }
}

public extension EllipticCurve {
    func containsPoint(_ point: Point) -> Bool {
        fatalError()
    }
}

public extension EllipticCurve {
    static var zilliqa: EllipticCurve {
        fatalError()
    }
}



// py27_keys.py
//def Bitcoin():
//a=0
//b=7
//p=2**256-2**32-2**9-2**8-2**7-2**6-2**4-1
//Gx=int("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798",16)
//Gy=int("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8",16)
//n=int("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141",16)
//
//return EllipticCurvePoint([Gx,Gy,1],a,b,p,n)

//# Certicom secp256-k1
//_a = 0x0000000000000000000000000000000000000000000000000000000000000000
//_b = 0x0000000000000000000000000000000000000000000000000000000000000007
//_p = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f
//_Gx = 0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798
//_Gy = 0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8
//_r = 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141
//
//curve_secp256k1 = ellipticcurve.CurveFp(_p, _a, _b)
//generator_secp256k1 = ellipticcurve.Point(curve_secp256k1, _Gx, _Gy, _r)


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



public func pythonMod<N>(_ a: N, _ n: N) -> N where N: SignedInteger {
    precondition(n > 0, "modulus must be positive")
    func swiftMod(_ x: N, _ y: N) -> N {
        // Using Swift standard library modulus
        return x % y
    }

    if a == 0 {
        return 0
    } else if a > 0 {
        return swiftMod(a, n)
    } else if a < 0 {
        let absA = abs(a)
        return absA >= n ? swiftMod(absA, n) : (n - absA)
    } else {
        fatalError("This should never happen. Logic is flawed.")
    }
}

private func invMod<N>(_ a: N, _ n: N) -> N where N: SignedInteger {
    func whileMod(_ n: N, _ a: N) -> [N] {
        var a = a
        var n = n
        var m = [N]()
        while n > 0 {
            m.append(a/n)
            (a, n) = (n, pythonMod(a, n))
        }
        return m
    }

    var m: [N] = whileMod(n, a)
    var u: N = 1
    var v: N = 0
    while !m.isEmpty {
        (u, v) = (v, u - m.removeLast() * v)
    }
    return pythonMod(u, n)
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
        var G = self.G
        if G.z > 0 {
            G.x = (G.x * invMod(G.z, P)) % P
            G.y = (G.y * invMod(G.z, P)) % P
            G.z = 1
        } else if G.y > 0 {
            G.x = (G.x * invMod(G.y, P)) % P
            G.y = 1
        } else if G.x > 0 {
            G.x = 1
        } else {
            fatalError()
        }
        return Self.init(G: G, a: a, b: b, P: P, N: N)
    }




//    func normalize() -> EllipticCurveOverFiniteField {
//
//        if self.G.z == 1 {
//            self.G.x = (self.G.x * InvMod(self.G.z, self.P)) % self.P
//            self.G.y = (self.G.y * InvMod(self.G.z, self.P)) % self.P
//            self.G.z = 1
//        } else if self.G.y > 0 {
//            self.G.x = (self.G.x * InvMod(self.G.y, self.P)) % self.P
//            self.G.y = 1
//        } else if self.G.x > 0 {
//            self.G.x = 1
//        } else {
//            fatalError()
//        }
//    }
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
        let `self` = lhs
        let y = rhs
        var z = Self(a: self.a, b: self.b, P: self.P)
        let G = self.G
        let P = self.P
        let a = self.a

        if self == y {
            let d = pythonMod(2 * G.y * G.z, P)
            let d3 = pow(d, 3, pythonMod: P)
            let n = pythonMod((3 * pow(G.x, 2, pythonMod: P) + a * pow(G.z, 2, pythonMod: P)), P)
            z.G.x = pythonMod((pow(n, 2, pythonMod: P) * d * G.z - 2 * d3 * G.x), P)
            z.G.y = pythonMod((3 * G.x * n * pow(d, 2, pythonMod: P) - pow(n, 3, pythonMod: P) * G.z - G.y * d3), P)
            z.G.z = pythonMod((G.z * d3), P)
        } else {
            let d = pythonMod((y.G.x * G.z - y.G.z * G.x), P)
            let d3 = pow(d, 3, pythonMod: P)
            let n = pythonMod((y.G.y * G.z - G.y * y.G.z), P)

            z.G.x = pythonMod((y.G.z * G.z * pow(n, 2, pythonMod: P) * d - d3 * (y.G.z * G.x + y.G.x * G.z)), P)
            z.G.y = pythonMod((pow(d, 2, pythonMod: P) * n * (2 * G.x * y.G.z + y.G.x * G.z) - pow(n, 3, pythonMod: P) * G.z * y.G.z - G.y * d3 * y.G.z), P)
            z.G.z = pythonMod((G.z * d3 * y.G.z), P)
        }

        return z
    }

    static func * (lhs: Self, rhs: Number) -> Self {
        guard rhs > 0 else {
            fatalError()
        }
        let `self` = lhs
        let n = rhs
        var (bits, _) = n.toBitArray()
        var t = Self(G: self.G, a: self.a, b: self.b, P: self.P)
        bits.removeLast()
        while !bits.isEmpty {
            t = t + t
            let bit = bits.removeLast()
            if bit.isOne {
                t = t + self
            }
        }

        return t
    }
}

extension Number {
    /// Returns the remainder of this integer raised to the power `exponent` in modulo arithmetic under `modulus`.
    ///
    /// Uses the [right-to-left binary method][rtlb].
    ///
    /// [rtlb]: https://en.wikipedia.org/wiki/Modular_exponentiation#Right-to-left_binary_method
    ///
    /// - Complexity: O(exponent.count * modulus.count^log2(3)) or somesuch
    public func power(_ exponent: BigInt, pythonMod modulus: BigInt) -> BigInt {
        precondition(!modulus.isZero)
        if modulus.magnitude == 1 { return 0 }
        if exponent.isZero { return 1 }
        if exponent == 1 { return pythonMod(self, modulus) }
        if exponent < 0 {
            precondition(!self.isZero)
            guard magnitude == 1 else { return 0 }
            guard sign == .minus else { return 1 }
            guard case let firstWord = exponent.magnitude.words[0], firstWord & 1 != 0 else { return 1 }
            return BigInt(modulus.magnitude - 1)
        }
        let power = self.magnitude.power(exponent.magnitude, modulus: modulus.magnitude)
        let firstWord = exponent.magnitude.words[0]
        if self.sign == .plus || firstWord & 1 == 0 || power.signum() == 0 {
            return BigInt(power)
        }
        return BigInt(modulus.magnitude - power)
    }
}

public func pow(_ base: Number, _ exponent: Number, pythonMod mod: Number) -> Number {
    return base.power(exponent, pythonMod: mod)
}

//public func pow(_ base: Number, _ exponent: Number, _ modulus: Number) -> Number {
//    return base.power(exponent, modulus: modulus)
//}

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

//public extension EllipticCurveOverFiniteField {
//    static var Generator: (x: Number, y: Number) {
//        return G
//    }
//
//    static func * (lhs: Number, rhs: Self) -> Number {
//        guard lhs > 0 else {
//            fatalError()
//        }
//
//        let n = lhs
//        let b = n.toBitArray()
//        let t =
//
//
////        #The fast multiplication of point n times by itself.
////        b=Base(n,2)
////        t=EllipticCurvePoint(self.x, self.a, self.b, self.p)
////        b.pop()
////        while b:
////        t+=t
////        if b.pop():
////        t+=self
////
////        return t
//
//    }
//}





//public struct Secp256k1: EllipticCurveOverFiniteField {
//    //    public struct FFInt: FiniteFieldInteger {
//    //        public static var Characteristic: UInt256 = Parameters.P
//    //        public static var InverseCharacteristic: (high: UInt256, low: UInt256)? = Parameters.InverseP
//    //        public var value: UInt256
//    //
//    //        public init() {
//    //            value = 0
//    //        }
//    //    }
//
//    public static var Generator = Secp256k1(withCoordinates: Parameters.G)
//    public static var Order: Number = Parameters.N
//    //    public static var InverseOrder: (high: UInt256, low: UInt256)? = Parameters.InverseN
//
//    public static var a = Parameters.a
//    public static var b = Parameters.b
//
//    public var x: Number
//    public var y: Number?
//
//    public init() {
//        x = 0
//    }
//}
