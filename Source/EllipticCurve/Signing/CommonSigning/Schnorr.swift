//
//  Schnorr.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-16.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct Schnorr<CurveType: EllipticCurve>: Signing {
    public typealias Curve = CurveType
}

public extension Schnorr {

    static func sign(_ message: Message, using keyPair: KeyPair<CurveType>, personalizationDRBG: Data) -> Signature<Curve> {

        let privateKey = keyPair.privateKey
        let publicKey = keyPair.publicKey

        let drbg = HMAC_DRBG(message: message, privateKey: privateKey, personalization: personalizationDRBG)

        let length = Curve.N.asTrimmedData().bytes.count

        var signature: Signature<Curve>?
        while signature == nil {
            let k = drbg.generateNumberOf(length: length).result
            let K = Number(data: k)
            signature = trySign(message, privateKey: privateKey, k: K, publicKey: publicKey)
        }

        return signature!
    }

    static func verify(_ message: Message, wasSignedBy signature: Signature<Curve>, publicKey: PublicKey<Curve>) -> Bool {
        guard publicKey.point.isOnCurve() else { return false }
        let r = signature.r
        let s = signature.s
        let e = Crypto.sha2Sha256(r.as256bitLongData() + publicKey.data.compressed + message.asData()).toNumber()

        guard
            let R = Curve.addition((Curve.G * s), (publicKey.point * (Curve.N - e))),
            jacobi(R) == 1,
            R.x == r /// When Jacobian: `R.x == r` can be changed to `R.x == ((R.z)^2 * r) % P.`
            else { return false }

        return true
    }
}

@testable import CryptoSwift

public protocol Hasher {
    var type: HashType { get }
    var digestLength: Int { get }
    var blockSize: Int { get }
    func digest() -> Data
    func calculate(_ data: Data) -> Data
}

public extension Hasher {
    func calculate(_ bytes: [Byte]) -> Data {
        return calculate(Data(bytes))
    }
}

extension Hasher where Self: CryptoSwift.DigestType {
    public func digest() -> Data {
        let one = calculate([])
        let two = calculate([])
        precondition(one == two)
        precondition(two == calculate([]))
        return Data(one)
    }
}

public protocol UpdatableHasher: Hasher, AnyObject {
    @discardableResult
    func update(_ data: Data) -> Self
}
public extension UpdatableHasher {
    @discardableResult
    func update(_ bytes: [Byte]) -> Self {
        return update(Data(bytes))
    }

    func newHasher() -> Self {
        return UpdatableHashProvider.hasher(variant: type) as! Self
    }
}

extension CryptoSwift.SHA2: UpdatableHasher {
    public func update(_ data: Data) -> CryptoSwift.SHA2 {
        let before = digest()
        precondition(before == digest())
        _ = try! self.update(withBytes: data.bytes.slice, isLast: false)
        let after = digest()
        precondition(after != before)
        precondition(after == digest())
        return self
    }

    public func calculate(for data: Data) -> Data {
        return update(data.bytes).digest()
    }


    public var type: HashType {
        switch variant {
        case .sha256: return HashType.sha2sha256
        default: fatalError("not supported yet")
        }
    }

    public func calculate(_ data: Data) -> Data {
        return Data(calculate(for: data.bytes))
    }
}

public final class UpdatableHashProvider {
    public static func hasher(variant: HashType) -> UpdatableHasher {
        switch variant {
        case .sha2sha256: return CryptoSwift.SHA2(variant: .sha256)
        }
    }
}

public enum HashType {
    case sha2sha256
}

typealias ByteArray = [Byte]

extension HashType {
    var hmac: HMAC.Variant {
        switch self {
        case .sha2sha256: return .sha256
        }
    }
}


struct HMACUpdatable {

    private var _digest: ByteArray
    private let hmac: HMAC
    private let hashType: HashType

    init(key: ByteArray, data: ByteArray?, hash: HashType = .sha2sha256) {
        self.hashType = hash
        let variant = hash.hmac
        let hmac = HMAC(key: key, variant: variant)
        if let data = data {
            let digest = try! hmac.authenticate(data)
            self.hmac = HMAC(key: digest)
            self._digest = digest
        } else {
            _digest = key
            self.hmac = hmac
        }
    }

    func digest() -> ByteArray {
        return _digest
    }
    func update(_ bytes: ByteArray) -> HMACUpdatable {
        return HMACUpdatable(key: _digest, data: bytes, hash: hashType)
    }
}
extension HMACUpdatable {
    init(key: Data, data: Data?, hash: HashType = .sha2sha256) {
        self.init(key: key.bytes, data: data?.bytes, hash: hash)
    }
    init(key: Data, data: String, encoding: String.Encoding = .utf8, hash: HashType = .sha2sha256) {
        self.init(key: key, data: data.data(using: encoding), hash: hash)
    }
    init(key: String, data: String, encoding: String.Encoding = .utf8, hash: HashType = .sha2sha256) {
        guard let key = key.data(using: encoding) else { fatalError("unhandled") }
        self.init(key: key, data: data, encoding: encoding, hash: hash)
    }

    func hexDigest() -> String {
        return Data(digest()).toHexString()
    }
}

public protocol DataConvertible { //: ExpressibleByArrayLiteral, ExpressibleByStringLiteral {
    var asData: Data { get }
    var asHex: String { get }
    init(data: Data)
}

extension DataConvertible {
    public var asHex: String {
        return asData.toHexString()
    }
}

extension HMACUpdatable: DataConvertible {
    var asData: Data {
        return Data(digest())
    }
    init(data: Data) {
        fatalError()
    }
}

extension Array: DataConvertible where Element == Byte {
    public var asData: Data { return Data(self) }
    public init(data: Data) {
        self.init(data.bytes)
    }
}

extension Data: DataConvertible {
    public var asData: Data { return self }
    public init(data: Data) {
        self = data
    }
}

//extension DataConvertible {
//    public init(arrayLiteral bytes: Byte...) {
//        self.init(data: Data(bytes))
//    }
//    public init(stringLiteral hex: String) {
//        self.init(data: Number(hexString: hex)!.asTrimmedData())
//    }
//}

//func = (lhs: inout DataConvertible, rhs: DataConvertible) {
//    fatalError()
//}

/// hmac-drbg
public final class HMAC_DRBG {

    /// Typically SHA2.sha256
    private let hasher: UpdatableHasher

    //    /// A Private Key could be used as entropy
    //    private let entropy: Data
    //
    //    /// A message to sign by some signer could be used as nonce
    //    private let nonce: Data
    //
    //    /// Often called `pers`
    //    private let personalization: Data

    private var K: DataConvertible
    private var V: DataConvertible
    private let minimumEntropyByteCount: Int
    private var iterationsLeftUntilReseed: Number
    private static let reseedInterval: Number = 0x1000000000000
    private var hashType: HashType {
        return hasher.type
    }

    func hmac(_ key: DataConvertible, _ data: DataConvertible) -> HMACUpdatable {
        return HMACUpdatable(key: key.asData, data: data.asData, hash: hashType)
    }

    public init(
        hasher: UpdatableHasher = UpdatableHashProvider.hasher(variant: .sha2sha256),
        entropy: Data,
        nonce: Data,
        personalization: Data? = nil,
        additionalInput: Data? = nil,
        minimumEntropyByteCount: Int? = nil,
        expected: (initV: String, initK: String)? = nil
        ) {
        self.hasher = hasher
        self.iterationsLeftUntilReseed = HMAC_DRBG.reseedInterval
        self.minimumEntropyByteCount = {
            guard let minimumEntropyByteCount = minimumEntropyByteCount else {
                switch hasher.type {
                    // https://github.com/indutny/hash.js/blob/9db0a25077e0237e91c1257552a8d37df1c6e17a/lib/hash/sha/256.js#L56
                case .sha2sha256: return 192/8
                }
            }
            return minimumEntropyByteCount
        }()
        precondition(hasher.digestLength == 32)
        self.K = Data(repeating: 0x00, count: hasher.digestLength)
        self.V = Data(repeating: 0x01, count: hasher.digestLength)

        let seed = entropy + nonce + (personalization ?? Data())
        print("🌳 Seed: \(Number(data: seed))")
        updateSeed(seed)

        if let expected = expected {
            precondition(V.asHex == expected.initV, "V: `\(V.asHex)`, but expected: `\(expected.initV)`")
            precondition(K.asHex == expected.initK)
        }
    }
}

//func d(_ data: Data, _ variable: String) {
//    let number = Number(data: data)
//    print("\(variable): \(number)")
//}
//
//func d(_ hmac: UpdatableHMAC, _ variable: String) {
//    d(hmac.digest(), variable)
//}

func + (data: DataConvertible, byte: Byte) -> Data {
    return data.asData + Data([byte])
}

func + (data: Data, byte: Byte) -> Data {
    return data + Data([byte])
}

func + (lhs: Data, rhs: Data?) -> Data {
    guard let rhs = rhs else { return lhs }
    return lhs + rhs
}

extension Data: ExpressibleByArrayLiteral {
    public init(arrayLiteral bytes: Byte...) {
        self.init(bytes: bytes)
    }
}

private extension HMAC_DRBG {

    func updateSeed(_ _seed: Data? = nil) {
        let seed = _seed ?? Data()
        func update(_ magicByte: Byte) {
            K = hmac(K, V + magicByte + seed)
            V = hmac(K, V)
        }
        update(0x00)
        if _seed == nil { return }
        update(0x01)

    }
}

public extension HMAC_DRBG {

    convenience init<Curve>(message: Message, privateKey: PrivateKey<Curve>, personalization: Data?) {
        self.init(entropy: privateKey.asData(), nonce: message.asData(), personalization: personalization)
    }

    func reseed(entropy: Data, additionalData: Data = Data()) {
        defer { iterationsLeftUntilReseed = HMAC_DRBG.reseedInterval }
        precondition(entropy.count >= minimumEntropyByteCount, "Not enough entropy. Minimum is #\(minimumEntropyByteCount) bytes")
        updateSeed(entropy + additionalData)
    }

    func generateNumberOf(length: Int, additionalData: Data? = nil) -> (result: Data, state: KeyValue) {
        defer {
            if let additionalData = additionalData {
                updateSeed(additionalData)
            }
            iterationsLeftUntilReseed -= 1
        }
        guard iterationsLeftUntilReseed > 0 else {
            fatalError("Reseed is required")
        }

        precondition(length == 128)

        if let additionalData = additionalData {
            updateSeed(additionalData)
        }

        var generated = Data()
        while generated.count < length {
            V = hmac(K, V).digest()
            generated += V.asData
        }
        generated = generated.prefix(length)
        updateSeed(additionalData)
        return (result: generated, state: KeyValue(v: V.asHex, key: K.asHex))
    }
}

/// Only for unit tests
public struct KeyValue: Codable {
    enum CodingKeys: String, CodingKey {
        case v = "V"
        case key = "Key"
    }
    let v: String
    let key: String
}


private extension Schnorr {

    /// Hash (q | M)
    static func hash(_ q: Data, message: Message, publicKey: PublicKey<Curve>) -> Data {
        let compressPubKey = publicKey.data.compressed
        let msgData = message.asData()
        // Public key is a point (x, y) on the curve.
        // Each coordinate requires 32 bytes.
        // In its compressed form it suffices to store the x co-ordinate
        // and the sign for y.
        // Hence a total of 33 bytes.
        let PUBKEY_COMPRESSED_SIZE_BYTES: Int = 33
        precondition(compressPubKey.bytes.count == PUBKEY_COMPRESSED_SIZE_BYTES)

        // TODO ensure BIG ENDIAN
        precondition(q.bytes.count >= PUBKEY_COMPRESSED_SIZE_BYTES)
        let Q = Data(q.bytes.prefix(PUBKEY_COMPRESSED_SIZE_BYTES))

        return Crypto.sha2Sha256(Q + compressPubKey + msgData)
    }

    static func trySign(_ message: Message, privateKey: PrivateKey<Curve>, k: Number, publicKey: PublicKey<Curve>) -> Signature<Curve> {

        guard privateKey.number > 0 else { fatalError("bad private key") }
        guard privateKey.number < Curve.order else { fatalError("bad private key") }

        // 1a. check that k is not 0
        guard k > 0 else { fatalError("bad k") }
        // 1b. check that k is < the order of the group
        guard k < Curve.order else { fatalError("bad k") }

        // 2. Compute commitment Q = kG, where g is the base point
        let Q = Curve.G * k
        // convert the commitment to octets first
        let compressedQ = PublicKey(point: Q).data.compressed

        // 3. Compute the challenge r = H(Q || pubKey || msg)
        let r = Number(data: hash(compressedQ, message: message, publicKey: publicKey))

        guard r > 0 else { fatalError("bad r") }
        guard r <= Curve.order else { fatalError("bad r") }

        // 4. Compute s = k - r * prv
        let s = Curve.modN { k - (r * privateKey.number) }

        guard s > 0 else { fatalError("bad S") }

        return Signature<Curve>(r: r, s: s)!
    }

    /// "Jacobian coordinates Elliptic Curve operations can be implemented more efficiently by using Jacobian coordinates. Elliptic Curve operations implemented this way avoid many intermediate modular inverses (which are computationally expensive), and the scheme proposed in this document is in fact designed to not need any inversions at all for validation. When operating on a point P with Jacobian coordinates (x,y,z), for which x(P) is defined as `x/z^2` and y(P) is defined as `y/z^3`"
    /// REFERENCE TO: https://en.wikibooks.org/wiki/Cryptography/Prime_Curve/Jacobian_Coordinates
    ///
    /// WHEN Jacobian Coordinates: "jacobi(point.y) can be implemented as jacobi(point.y * point.z mod P)."
    //
    /// Can be computed more efficiently using an extended GCD algorithm.
    /// reference: https://en.wikipedia.org/wiki/Jacobi_symbol#Calculating_the_Jacobi_symbol
    static func jacobi(_ point: Curve.Point) -> Number {
        func jacobi(_ number: Number) -> Number {
            let division = (Curve.P - 1).quotientAndRemainder(dividingBy: 2)
            return number.power(division.quotient, modulus: Curve.P)
        }
        return jacobi(point.y) // can be changed to jacobi(point.y * point.z % Curve.P)
    }
}

