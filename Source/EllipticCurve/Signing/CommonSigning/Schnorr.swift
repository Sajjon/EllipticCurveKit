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
            let k = drbg.generateNumberOf(length: length)
            signature = trySign(message, privateKey: privateKey, k: k, publicKey: publicKey)
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
        assert(one == two)
        assert(two == calculate([]))
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
        assert(before == digest())
        _ = try! self.update(withBytes: data.bytes.slice, isLast: false)
        let after = digest()
        assert(after != before)
        assert(after == digest())
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

public final class UpdatableHMAC {

    private var inner: UpdatableHasher
    private var outer: UpdatableHasher
    private let hasher: UpdatableHasher

    public init(key: Data, hasher: UpdatableHasher) {
        self.hasher = hasher

        var key = key.bytes

        // Shorten key, if needed
        if key.count > hasher.blockSize {
            key = hasher.calculate(key).bytes
        }
        assert(key.count <= hasher.blockSize)

        // Add padding to key
        for _ in key.count..<hasher.blockSize {
            key.append(0x0)
        }

        for i in 0..<key.count {
            key[i] ^= 0x36
        }
        self.inner = hasher.newHasher().update(key)

        // 0x36 ^ 0x5c = 0x6a
        for i in 0..<key.count {
            key[i] ^= 0x6a;
        }
        self.outer = hasher.newHasher().update(key)
    }
}

// MARK: - UpdatableHasher
extension UpdatableHMAC: UpdatableHasher {}
public extension UpdatableHMAC {

    var type: HashType {
        return hasher.type
    }

    var blockSize: Int {
        return hasher.blockSize
    }

    var digestLength: Int {
        return hasher.digestLength
    }

    func calculate(_ data: Data) -> Data {
        fatalError("what to do?")
    }

    func digest() -> Data {
        let outer0 = outer.digest()
        assert(outer0 == outer.digest())
        let inner0 = inner.digest()
        assert(inner0 == inner.digest())
        outer.update(inner.digest())
        assert(outer.digest() != outer0)
        return outer.digest()
    }

    func update(_ data: Data) -> Self {
        print("inner: \(Number(data: inner.digest())), outer: \(Number(data: outer.digest()))")
        inner.update(data)
        return self
    }
}


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

    private var K: Data
    private var V: Data
    private let minimumEntropyByteCount: Int
    private var iterationsLeftUntilReseed: Number
    private static let reseedInterval: Number = 0x1000000000000

    func hmac() -> UpdatableHMAC {
        return UpdatableHMAC(key: K, hasher: hasher)
    }

    public init(
        hasher: UpdatableHasher = UpdatableHashProvider.hasher(variant: .sha2sha256),
        entropy: Data,
        nonce: Data,
        personalization: Data? = nil,
        additionalInput: Data? = nil,
        minimumEntropyByteCount: Int? = nil
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
        assert(hasher.digestLength == 32)
        self.K = Data(repeating: 0x00, count: hasher.digestLength)
        self.V = Data(repeating: 0x01, count: hasher.digestLength)

        let seed = entropy + nonce + (personalization ?? Data())
        print("🌳 Seed: \(Number(data: seed))")
        updateSeed(seed)
    }
}

func d(_ data: Data, _ variable: String) {
    let number = Number(data: data)
    print("\(variable): \(number)")
}

func d(_ hmac: UpdatableHMAC, _ variable: String) {
    d(hmac.digest(), variable)
}

private extension HMAC_DRBG {
    func updateSeed(_ seed: Data?) {
        var kmac = hmac()
//        d(kmac, "kmac")
        kmac = kmac.update(V)
            .update([0x00])

//        d(kmac, "kmac")
        kmac = kmac.update(seed)
//        d(kmac, "kmac")
        K = kmac.digest()
//        d(K, "K")
        V = hmac()
            .update(V)
            .digest()

//        d(V, "V")

        K = hmac()
            .update(V)
            .update(Data([0x01]))
            .update(seed)
            .digest()

//        d(K, "K")

        V = hmac()
            .update(V)
            .digest()

//        d(V, "V")
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

    func generateNumberOf(length: Int, additionalData: Data? = nil) -> Number {
        defer { iterationsLeftUntilReseed -= 1 }
        guard iterationsLeftUntilReseed > 0 else {
            fatalError("Reseed is required")
        }

        updateSeed(additionalData)

        var temp = Data()
        while temp.count < length {
            print("💎 V: \(Number(data: V))")
            V = hmac().update(V).digest()
            temp += V
        }
        let result = temp.prefix(length)
        updateSeed(additionalData)
        return Number(data: result)
    }
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
        assert(compressPubKey.bytes.count == PUBKEY_COMPRESSED_SIZE_BYTES)

        // TODO ensure BIG ENDIAN
        assert(q.bytes.count >= PUBKEY_COMPRESSED_SIZE_BYTES)
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

