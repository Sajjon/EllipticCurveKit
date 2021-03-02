//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-03-02.
//

import Foundation
import CryptoKit



public protocol SymmetricKeyDerivationFunction {
    func derive(
        ephemeralPublicKey: PublicKey<Secp256k1>,
        alicePrivateKey: PrivateKey<Secp256k1>,
        bobPublicKey: PublicKey<Secp256k1>
    ) -> CryptoKit.SymmetricKey
}

/// Derivation of a symmetric key using a modified Diffie-Hellman key exchange between
/// Alice, Bob and an ephemeral public key by computing:
///
///     S = aB + E
///     x = S.x
///     key = SHA256(x)
///
/// This scheme is different is not vanilla DH nor vanilla ECIES KDF, but a variant
/// developed by Alexander Cyon, and presented on [Crypto StackExchange here][cyonECIES].
///
/// [cyonECIES]: https://crypto.stackexchange.com/questions/88083/modified-ecies-using-ec-point-add-with-dh-key
///
public struct ECAddDiffieHellmanKDF: SymmetricKeyDerivationFunction {
    public func derive(
        ephemeralPublicKey E: PublicKey<Secp256k1>,
        alicePrivateKey a: PrivateKey<Secp256k1>,
        bobPublicKey B: PublicKey<Secp256k1>
    ) -> CryptoKit.SymmetricKey {
        let aB = a * B
        let S = aB + E
        let x = S.x
        
        var hasher = SHA256()
        hasher.update(data: Data(hex: x.asHexString()))
        let keyData = Data(hasher.finalize())
        
        return .init(data: keyData)
    }
}

/// Encrypt and Decrypt data using [ECIES][ecies] (Elliptic Curve Integrated Encryption Scheme)
/// - a subset of DHIES.
///
/// [ecies]: https://en.wikipedia.org/wiki/Integrated_Encryption_Scheme
///
public struct ECIES {
    
    private let symmetricKeyDerivationFunction: SymmetricKeyDerivationFunction
    
    public init(
        symmetricKeyDerivationFunction: SymmetricKeyDerivationFunction
    ) {
        self.symmetricKeyDerivationFunction = symmetricKeyDerivationFunction
    }
}

public extension ECIES {
    struct SealedBox {
        
        /// The nonce used to encrypt the data.
        public let nonce: Nonce
        
        /// The public key of the
        public let ephemeralPublicKey: PublicKey<Secp256k1>
        
        /// An authentication tag.
        public let tag: Data
        
        /// The encrypted data.
        public let ciphertext: Data
    }
}


private extension ECIES.SealedBox {

    
    init(combinedData: Data) throws {
        // Sanity check of length
        guard combinedData.count >= ByteCountOf.combinedExcludingCipherText else {
            throw ECIES.DecryptionError.ciphertextCannotBeEmpty
        }
        
        // Parse `Nonce`
        let nonceData = combinedData.subdata(in: 0..<ByteCountOf.nonce)
        self.nonce = try Nonce(data: nonceData)
        
        // Parse `Ephemeral Public Key`
        let keyStartIndex = ByteCountOf.nonce
        let keyEndIndex = keyStartIndex + ByteCountOf.ephemeralPublicKeyCompressed
        let ephemeralPublicKeyCompressedData = combinedData.subdata(in: keyStartIndex..<keyEndIndex)
        
        guard
            let ephemeralPublicKeyPoint = try? AffinePoint<Secp256k1>.decodeFromCompressedPublicKey(
                bytes: ephemeralPublicKeyCompressedData
            ) else {
            throw ECIES.DecryptionError.failedToDecodeBytesToPublicKeyPoint
        }
        self.ephemeralPublicKey = PublicKey<Secp256k1>(point: ephemeralPublicKeyPoint)
        
        
        // Parse `Tag`
        let tagStartIndex = ByteCountOf.nonce + ByteCountOf.ephemeralPublicKeyCompressed
        let tagEndIndex = tagStartIndex + ByteCountOf.tag
        self.tag = combinedData.subdata(in: tagStartIndex..<tagEndIndex)
        
        // Parse `cipher`
        self.ciphertext = combinedData.subdata(in: ByteCountOf.combinedExcludingCipherText..<combinedData.count)
        
    }
    
}


public extension ECIES.SealedBox {
    
    /// A value used once during a cryptographic operation, and then discarded.
    typealias Nonce = CryptoKit.AES.GCM.Nonce
    
    struct ByteCountOf {
        static let ephemeralPublicKeyCompressed = 33
        static let nonce = 12
        static let tag = 16
        static let combinedExcludingCipherText = ephemeralPublicKeyCompressed + nonce + tag
        static func ciphertext(givenCombinedDataByteCount: Int) -> Int {
            givenCombinedDataByteCount - combinedExcludingCipherText
        }
    }
    
    static let byteCountOf = ByteCountOf()
    
    /// The combined representation ( nonce || ephemeralPublicKeyCompressed || tag || ciphertext)
    var combined: Data {
        var combined = Data(nonce)
        combined.append(ephemeralPublicKey.data.compressed)
        combined.append(tag)
        combined.append(ciphertext)
        return combined
    }
    
}

extension CryptoKitError: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.authenticationFailure, .authenticationFailure): return true
        case (.incorrectKeySize, .incorrectKeySize): return true
        case (.incorrectParameterSize, .incorrectParameterSize): return true
        case (.underlyingCoreCryptoError(let lhsError), .underlyingCoreCryptoError(let rhsError)): return lhsError == rhsError
        default:
            return false
        }
    }
}

public extension ECIES {
    
    enum EncryptionError: Swift.Error, Equatable {
        case encodingError
        case symmetricEncryptionFailed(CryptoKitError)
    }
    
    enum DecryptionError: Swift.Error, Equatable {
        case decodingError
        case failedToDecodeBytesToPublicKeyPoint
        case ciphertextCannotBeEmpty
        case symmetricDecryptionFailed(CryptoKitError)
    }
    
    
    /// Secures the given plaintext message with encryption and an authentication tag.
    ///
    /// - Parameters:
    ///   - message: The plaintext data to seal.
    ///   - recipientPublicKey: A cryptographic public key used to seal the message.
    ///   - senderPrivateKey: A cryptographic private key used to seal the message.
    ///   - nonce: A nonce used during the sealing process.
    /// - Returns: The sealed message.
    func seal<Plaintext>(
        _ message: Plaintext,
        recipientPublicKey: PublicKey<Secp256k1>,
        senderPrivateKey: PrivateKey<Secp256k1>,
        nonce: SealedBox.Nonce? = nil
    ) -> Result<SealedBox, EncryptionError> where Plaintext: DataProtocol {
        
        let nonce = nonce ?? .init()
        
        let ephemeralKeyPair = KeyPair<Secp256k1>.init(private: .init())
        let ephemeralPublicKey = ephemeralKeyPair.publicKey
        
        let symmetricKey = symmetricKeyDerivationFunction.derive(
            ephemeralPublicKey: ephemeralPublicKey,
            alicePrivateKey: senderPrivateKey,
            bobPublicKey: recipientPublicKey
        )
        
        let symmetricSealedBox: AES.GCM.SealedBox
        do {
            
            symmetricSealedBox = try AES.GCM.seal(
                message,
                using: symmetricKey,
                nonce: nonce
            )
            
        } catch let error as CryptoKitError {
            return .failure(.symmetricEncryptionFailed(error))
        } catch {
            fatalError("Wrong error type")
        }
        
        let sealedBox = SealedBox(
            nonce: symmetricSealedBox.nonce,
            ephemeralPublicKey: ephemeralPublicKey,
            tag: symmetricSealedBox.tag,
            ciphertext: symmetricSealedBox.ciphertext
        )
        return .success(sealedBox)
        
    }
    
    /// Decrypts the message and verifies the authenticity of both the encrypted message and additional data.
    func open(
        _ sealedBox: SealedBox,
        alicePublicKey: PublicKey<Secp256k1>,
        bobPrivateKey: PrivateKey<Secp256k1>
    ) -> Result<Data, DecryptionError> {
        
        
        let ephemeralPublicKey = sealedBox.ephemeralPublicKey
        
        let symmetricKey = symmetricKeyDerivationFunction.derive(
            ephemeralPublicKey: ephemeralPublicKey,
            // looks confusing for sure, but we just use `alice` and
            // `bob` as labels for `entity one` and `entity two`.
            alicePrivateKey: bobPrivateKey,
            bobPublicKey: alicePublicKey
        )
        
        let decryptedData: Data
        do {
            
            decryptedData = try AES.GCM.open(
                .init(
                    nonce: sealedBox.nonce,
                    ciphertext: sealedBox.ciphertext,
                    tag: sealedBox.tag
                ),
                using: symmetricKey
            )
            
        } catch let error as CryptoKitError {
            return .failure(.symmetricDecryptionFailed(error))
        } catch {
            fatalError("Wrong error type")
        }
        
        return .success(decryptedData)
    }
    
    func open(
        sealedBoxCombinedData combinedData: Data,
        alicePublicKey: PublicKey<Secp256k1>,
        bobPrivateKey: PrivateKey<Secp256k1>
    ) -> Result<Data, DecryptionError> {
        
        let sealedBox: SealedBox
        do {
            sealedBox = try SealedBox(combinedData: combinedData)
        } catch let error as DecryptionError {
            return .failure(error)
        } catch { incorrectImplementation("Expected 'DecryptionError'") }
        
        return open(
            sealedBox,
            alicePublicKey: alicePublicKey,
            bobPrivateKey: bobPrivateKey
        )
    }
}

public extension ECIES {
    func encrypt(
        message: String,
        encoding: String.Encoding = .utf8,
        recipientPublicKey: PublicKey<Secp256k1>,
        senderPrivateKey: PrivateKey<Secp256k1>,
        nonce: SealedBox.Nonce? = nil
    ) throws -> SealedBox {
        
        guard let encodedMessage = message.data(using: encoding) else {
            throw EncryptionError.encodingError
        }
        
        return try seal(
            encodedMessage,
            recipientPublicKey: recipientPublicKey,
            senderPrivateKey: senderPrivateKey,
            nonce: nonce
        ).get()
    }
    
    func decrypt(
        sealedBox: SealedBox,
        encoding: String.Encoding = .utf8,
        alicePublicKey: PublicKey<Secp256k1>,
        bobPrivateKey: PrivateKey<Secp256k1>
    ) throws -> String {
        
        let decrypted = try open(
            sealedBox,
            alicePublicKey: alicePublicKey,
            bobPrivateKey: bobPrivateKey
        ).get()
        
        guard let plaintext = String(data: decrypted, encoding: encoding) else {
            throw DecryptionError.decodingError
        }
        
        return plaintext
    }
    
    
    func decrypt(
        data: Data,
        encoding: String.Encoding = .utf8,
        alicePublicKey: PublicKey<Secp256k1>,
        bobPrivateKey: PrivateKey<Secp256k1>
    ) throws -> String {
        
        let decrypted = try open(
            sealedBoxCombinedData: data,
            alicePublicKey: alicePublicKey,
            bobPrivateKey: bobPrivateKey
        ).get()
        
        guard let plaintext = String(data: decrypted, encoding: encoding) else {
            throw DecryptionError.decodingError
        }
        
        return plaintext
    }
    
}

