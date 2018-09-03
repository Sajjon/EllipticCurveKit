//
//  ECCBase.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-08-14.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import EquationKit

public enum NamedCurve {
    case secp256k1
    case secp256r1

    /// Not to be confused with Ed25519
    case curve25519

    /// Not to be confused with Curv25519
    case ed25519

    var curve: ECCBase {
        switch self {
        case .secp256k1: return EllipticCurveKit.secp256k1
        case .secp256r1: return EllipticCurveKit.secp256r1
        case .curve25519: return EllipticCurveKit.curve25519
        case .ed25519: return EllipticCurveKit.ed25519
        }
    }

    var name: String {
        return String(describing: type(of: curve))
    }
}

public enum Name {
    case named(NamedCurve)
    case custom(String)

    var name: String {
        switch self {
        case .named(let namedCurve): return namedCurve.name
        case .custom(let customName): return customName
        }
    }
}

public typealias EllipticCurveCryptography = KeyIssuer & AnySigner & AnySignatureVerifier

public protocol EllipticCurve {
    var name: Name { get }

    var form: CurveForm { get }
    var order: Number { get }
    var generator: TwoDimensionalPoint { get }
    var cofactor: Number { get }
    static func *(number: Number, curve: Self) -> TwoDimensionalPoint
    static func *(curve: Self, number: Number) -> TwoDimensionalPoint
}

// MARK: EllipticCurve operations
public extension EllipticCurve {
    static func *(number: Number, curve: Self) -> TwoDimensionalPoint {
        return curve.form.multiply(point: curve.generator, by: number)
    }

    static func *(curve: Self, number: Number) -> TwoDimensionalPoint {
        return number * curve
    }
}

public class ECCBase: EllipticCurve, EllipticCurveCryptography {

    public let name: Name

    /// The underlying elliptic curve form
    public let form: CurveForm

    /// Often called `N`
    public let order: Number

    /// Often called `base point` or `G`
    public let generator: TwoDimensionalPoint

    /// Often denoted `h`
    public let cofactor: Number

    public init(
        name: Name,
        form: CurveForm,
        order: Number,
        generator: TwoDimensionalPoint,
        cofactor: Number
        ) {
        self.name = name
        self.form = form
        self.order = order
        self.generator = generator
        self.cofactor = cofactor
    }

    // Overrideable (thus cannot be declared in an extension (yet...))
    public func securelyGeneratePrivateKeyNumber() -> Number {
        return securelyGeneratePrivateKeyNumber(in: 1..<order)
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

        guard r < form.galoisField.modulus, s < order, r > 0, s > 0 else { fatalError("bad values") }

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


public let secp256r1 = Secp256r1()
public class Secp256r1: ECCBase {
    public init() {
        super.init(
            name: .named(.secp256r1),
            form: ShortWeierstraßCurve(
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



private let parameters25519 = (galoisField: Field(2^^255 - 19), order: Number(2^^252 + Number(decimal: "27742317777372353535851937790883648493")))

public let curve25519 = Curve25519()
public class Curve25519: ECCBase {
    public override func securelyGeneratePrivateKeyNumber() -> Number {
        return securelyGeneratePrivateKeyNumber(in: 1..<order) {
            decodeScalar25519($0)
        }
    }

    /// Initializer for the named curve `Curve25519`
    public convenience init() {
        self.init(
            name: .named(.curve25519),
            form: MontgomeryCurve(
                a: 486662,
                b: 1,
                galoisField: parameters25519.galoisField,
                order: parameters25519.order
            )!,
            generator: AnyTwoDimensionalPoint(
                x: 9,
                y: Number(decimal: "14781619447589544791020593568409986887264606134616475288964881837755586237401")
            )
        )
    }

    /// Initializer for any transformation of `Curve25519`, e.g. `Ed25519`.
    public init(name: Name, form: CurveForm, generator: TwoDimensionalPoint) {
        super.init(
            name: name,
            form: form,
            order: parameters25519.order,
            generator: generator,
            cofactor: 8
        )
    }

}

public let ed25519 = Ed25519()
public class Ed25519: Curve25519 {
    public init() {
        super.init(
            name: .named(.ed25519),
            form: TwistedEdwardsCurve(
                a: -1,
                d: parameters25519.galoisField.modInverse(-121665, 121666),
                galoisField: parameters25519.galoisField
            )!,
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

