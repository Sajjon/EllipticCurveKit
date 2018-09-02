//
//  ECCBase.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-08-14.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import EquationKit


public class ECCBase: EllipticCurveCryptography {

    /// The underlying elliptic curve
    let curve: BaseCurveProtocol

    /// Often called `N`
    let order: Number

    /// Often called `base point` or `G`
    let generator: TwoDimensionalPoint

    /// Often denoted `h`
    let cofactor: Number

    public init(
        curve: BaseCurveProtocol,
        order: Number,
        generator: TwoDimensionalPoint,
        cofactor: Number
        ) {
        self.curve = curve
        self.order = order
        self.generator = generator
        self.cofactor = cofactor
    }

    // Overrideable (thus cannot be declared in an extension (yet...))
    public func securelyGeneratePrivateKeyNumber() -> Number {
        return securelyGeneratePrivateKeyNumber(in: 1..<order)
    }
}

// MARK: Curve operations
public extension ECCBase {
    static func *(number: Number, curve: ECCBase) -> TwoDimensionalPoint {
        return curve.curve.multiply(point: curve.generator, by: number)
    }

    static func *(curve: ECCBase, number: Number) -> TwoDimensionalPoint {
        return number * curve
    }
}

// MARK: KeyIssuer
public extension ECCBase {
    func generatePrivateKey() -> PrivateKey {
        return PrivateKey(number: securelyGeneratePrivateKeyNumber())
    }
}

// MARK: AnySigner
public extension ECCBase {

    func generateSignatureParts(message: Message, scheme: SignatureScheme, options: SigningOptions) -> SignatureParts {
        fatalError()
    }

    func createSignatureFromParts(_ parts: SignatureParts, options: SigningOptions) -> Signature {
        var (r, s) = parts

        guard r < curve.galoisField.modulus, s < order, r > 0, s > 0 else { fatalError("bad values") }

        if options.lowS, s > (order-1)/2 {
            s = order - s
        }

        return Signature(r: r, s: s)
    }

    func sign(message: Message, scheme: SignatureScheme) -> Signature {
        abstract
    }
}

// MARK: AnySignatureVerifier
public extension ECCBase {
    func verify(signature: Signature, scheme: SignatureScheme) -> Bool {
        abstract
    }
}



internal extension ECCBase {

    func securelyGeneratePrivateKeyNumber(in range: Range<Number>, modify: ((Number) -> Number)? = nil) -> Number {
        let byteCount = (order - 1).as256bitLongData().bytes.count
        var privateKey: Number!
        while privateKey == nil {
            guard let randomBytes = try? securelyRandomizeBytes(count: byteCount) else { continue }
            privateKey = Number(data: Data(bytes: randomBytes))
        }
        guard let modify = modify else {
            return privateKey
        }
        return modify(privateKey)
    }
}

public let secp256k1 = Secp256k1()
public class Secp256k1: ECCBase {
    public init() {
        super.init(
            curve: ShortWeierstraßCurve(
                a: 0,
                b: 7,
                // 2^256 −2^32 −2^9 −2^8 −2^7 −2^6 −2^4 − 1  <===>  2^256 - 2^32 - 977
                galoisField: "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F"
                )!,
            order: "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141",
            generator: AnyTwoDimensionalPoint(
                x: "0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798",
                y: "0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8"
            ),
            cofactor: 1
        )
    }
}

public let secp256r1 = Secp256r1()
public class Secp256r1: ECCBase {
    public init() {
        super.init(
            curve: ShortWeierstraßCurve(
                a: "0xFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFC",
                b: Number(hexString: "0x5AC635D8AA3A93E7B3EBBD55769886BC651D06B0CC53B0F63BCE3C3E27D2604B")!,
                /// 2^256 - 2^224 + 2^192 + 2^96 - 1  <===>  2^224 * (2^32 − 1) + 2^192 +2^96 − 1
                galoisField: Field("0xFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF")!
                )!,
            order: Number(hexString: "0xFFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551")!,
            generator: AnyTwoDimensionalPoint(
                x: Number(hexString: "0x6B17D1F2E12C4247F8BCE6E563A440F277037D812DEB33A0F4A13945D898C296")!,
                y: Number(hexString: "0x4FE342E2FE1A7F9B8EE7EB4A7C0F9E162BCE33576B315ECECBB6406837BF51F5")!
            ),
            cofactor: 1
        )
    }
}

public func decodeScalar25519(_ number: Number) -> Number {
    var bytes32 = number.as256bitLongData().bytes
    bytes32[0] &= Byte(248)
    bytes32[31] &= Byte(127)
    bytes32[31] |= Byte(64)
    return Number(data: Data(bytes32))
}



private let curve25519 = (galoisField: Field(2^^255 - 19), order: Number(2^^252 + Number(decimal: "27742317777372353535851937790883648493")))
class ECCBaseCurve25519: ECCBase {
    public override func securelyGeneratePrivateKeyNumber() -> Number {
        return securelyGeneratePrivateKeyNumber(in: 1..<order) {
            decodeScalar25519($0)
        }
    }

    public init(curve: BaseCurveProtocol? = nil, generator: TwoDimensionalPoint? = nil) {
        super.init(
            curve: curve ?? MontgomeryCurve(
                a: 486662,
                b: 1,
                galoisField: curve25519.galoisField,
                order: curve25519.order
                )!,
            order: curve25519.order,
            generator: generator ?? AnyTwoDimensionalPoint(
                x: 9,
                y: Number(decimal: "14781619447589544791020593568409986887264606134616475288964881837755586237401")
            ),
            cofactor: 8
        )
    }

}

public extension Number {
    init(decimal: String) {
        self.init(decimal, radix: 10)!
    }
}

class ECCEd25519: ECCBaseCurve25519 {
    public init() {
        super.init(
            curve: TwistedEdwardsCurve(
                a: -1,
                d: curve25519.galoisField.modInverse(-121665, 121666),
                galoisField: curve25519.galoisField
            ),
            generator: AnyTwoDimensionalPoint(
                x: Number(decimal: "15112221349535400772501151409588531511454012693041857206046113283949847762202"),
                y: Number(decimal: "46316835694926478169428394003475163141307993866256225615783033603165251855960")
            )
        )
    }
}

public protocol KeyIssuer {
    func generatePrivateKey() -> PrivateKey

}

public enum SignatureScheme {
    case ecdsa
    case schnorr

    /// Also known as "Ed25519"
    case eddsa
}

public typealias SignatureParts = (r: Number, s: Number)

public protocol AnySigner {
    func generateSignatureParts(message: Message, scheme: SignatureScheme, options: SigningOptions) -> SignatureParts
    func createSignatureFromParts(_ parts: SignatureParts, options: SigningOptions) -> Signature
    func sign(message: Message, scheme: SignatureScheme, options: SigningOptions) -> Signature
}

public extension AnySigner {

    func sign(message: Message, scheme: SignatureScheme, options: SigningOptions = .default) -> Signature {
        let parts = generateSignatureParts(message: message, scheme: scheme, options: options)
        return createSignatureFromParts(parts, options: options)
    }
}

public struct SigningOptions {
    /// `reduceS` according to BIP-62
    /// https://github.com/bitcoin/bips/blob/master/bip-0062.mediawiki#Low_S_values_in_signatures
    /// https://bitcoin.stackexchange.com/questions/38252/the-complement-of-s-when-s-curve-order-2
    /// https://bitcoin.stackexchange.com/questions/50980/test-r-s-values-for-signature-generation
    /// https://bitcointalk.org/index.php?topic=285142.msg3299061#msg3299061
    public let lowS: Bool
    public init(lowS: Bool = true) {
        self.lowS = lowS
    }
}


public extension SigningOptions {
    static var `default`: SigningOptions {
        if isDebug && isRunningUnitTests {
            return SigningOptions(lowS: false)
        }

        return SigningOptions(lowS: true)
    }
}

public protocol Signer: AnySigner {
    var signatureScheme: SignatureScheme { get }
    func sign(message: Message, options: SigningOptions) -> Signature
}
public extension Signer {
    func sign(message: Message, options: SigningOptions = .default) -> Signature {
        return sign(message: message, scheme: signatureScheme, options: options)
    }
}

public protocol AnySignatureVerifier {
    func verify(signature: Signature, scheme: SignatureScheme) -> Bool
}
public protocol SignatureVerifier: AnySignatureVerifier {
    var signatureScheme: SignatureScheme { get }
    func verify(signature: Signature) -> Bool
}
public extension SignatureVerifier {
    func verify(signature: Signature) -> Bool {
        return verify(signature: signature, scheme: signatureScheme)
    }
}

public typealias EllipticCurveCryptography = KeyIssuer & AnySigner & AnySignatureVerifier
