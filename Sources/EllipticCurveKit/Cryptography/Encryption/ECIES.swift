//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-03-02.
//

import Foundation
import CryptoKit



/// Encrypt and Decrypt data using [ECIES][ecies] (Elliptic Curve Integrated Encryption Scheme)
/// - a subset of DHIES.
///
/// [ecies]: https://en.wikipedia.org/wiki/Integrated_Encryption_Scheme
///
public struct ECIES {
    
    private let symmetricKeyDerivationFunction: SymmetricKeyDerivationFunction
    
    public init(
        symmetricKeyDerivationFunction: SymmetricKeyDerivationFunction = ECAddDiffieHellmanKDF()
    ) {
        self.symmetricKeyDerivationFunction = symmetricKeyDerivationFunction
    }
}

// MARK: Seal
public extension ECIES {
        
    /// Secures the given plaintext message with encryption and an authentication tag.
    ///
    /// - Parameters:
    ///   - message: The plaintext data to seal.
    ///   - whitePublicKey: A cryptographic public key used to seal the message.
    ///   - blackPrivateKey: A cryptographic private key used to seal the message.
    ///   - nonce: A nonce used during the sealing process.
    /// - Returns: The sealed message.
    func seal<Plaintext>(
        _ message: Plaintext,
        whitePublicKey: PublicKey<Secp256k1>,
        blackPrivateKey: PrivateKey<Secp256k1>,
        nonce: SealedBox.Nonce? = nil
    ) -> Result<SealedBox, EncryptionError> where Plaintext: DataProtocol {
        
        let nonce = nonce ?? .init()
        
        let ephemeralKeyPair = KeyPair<Secp256k1>.init(private: .init())
        let ephemeralPublicKey = ephemeralKeyPair.publicKey
        
        let symmetricKey = symmetricKeyDerivationFunction.derive(
            ephemeralPublicKey: ephemeralPublicKey,
            blackPrivateKey: blackPrivateKey,
            whitePublicKey: whitePublicKey
        )
        
        let symmetricSealedBox: AES.GCM.SealedBox
 
        do {
            
            symmetricSealedBox = try AES.GCM.seal(
                message,
                using: symmetricKey,
                nonce: nonce,
                authenticating: ephemeralPublicKey.data.compressed
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
}

// MARK: Open
public extension ECIES {
    /// Decrypts the message and verifies the authenticity of both the encrypted message and additional data.
    func open(
        _ sealedBox: SealedBox,
        whitePublicKey: PublicKey<Secp256k1>,
        blackPrivateKey: PrivateKey<Secp256k1>
    ) -> Result<Data, DecryptionError> {
        
        
        let ephemeralPublicKey = sealedBox.ephemeralPublicKey
        
        let symmetricKey = symmetricKeyDerivationFunction.derive(
            ephemeralPublicKey: ephemeralPublicKey,
            blackPrivateKey: blackPrivateKey,
            whitePublicKey: whitePublicKey
        )
        
        let decryptedData: Data
        do {
            
            decryptedData = try AES.GCM.open(
                .init(
                    nonce: sealedBox.nonce,
                    ciphertext: sealedBox.ciphertext,
                    tag: sealedBox.tag
                ),
                using: symmetricKey,
                authenticating: ephemeralPublicKey.data.compressed
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
        whitePublicKey: PublicKey<Secp256k1>,
        blackPrivateKey: PrivateKey<Secp256k1>
    ) -> Result<Data, DecryptionError> {
        
        let sealedBox: SealedBox
        do {
            sealedBox = try SealedBox(combinedData: combinedData)
        } catch let error as DecryptionError {
            return .failure(error)
        } catch { incorrectImplementation("Expected 'DecryptionError'") }
        
        return open(
            sealedBox,
            whitePublicKey: whitePublicKey,
            blackPrivateKey: blackPrivateKey
        )
    }
}

// MARK: Sugar
public extension ECIES {
    func encrypt(
        message: String,
        encoding: String.Encoding = .utf8,
        whitePublicKey: PublicKey<Secp256k1>,
        blackPrivateKey: PrivateKey<Secp256k1>,
        nonce: SealedBox.Nonce? = nil
    ) throws -> SealedBox {
        
        guard let encodedMessage = message.data(using: encoding) else {
            throw EncryptionError.encodingError
        }
        
        return try seal(
            encodedMessage,
            whitePublicKey: whitePublicKey,
            blackPrivateKey: blackPrivateKey,
            nonce: nonce
        ).get()
    }
    
    func decrypt(
        sealedBox: SealedBox,
        encoding: String.Encoding = .utf8,
        whitePublicKey: PublicKey<Secp256k1>,
        blackPrivateKey: PrivateKey<Secp256k1>
    ) throws -> String {
        
        let decrypted = try open(
            sealedBox,
            whitePublicKey: whitePublicKey,
            blackPrivateKey: blackPrivateKey
        ).get()
        
        guard let plaintext = String(data: decrypted, encoding: encoding) else {
            throw DecryptionError.decodingError
        }
        
        return plaintext
    }
    
    
    func decrypt(
        data: Data,
        encoding: String.Encoding = .utf8,
        whitePublicKey: PublicKey<Secp256k1>,
        blackPrivateKey: PrivateKey<Secp256k1>
    ) throws -> String {
        
        let decrypted = try open(
            sealedBoxCombinedData: data,
            whitePublicKey: whitePublicKey,
            blackPrivateKey: blackPrivateKey
        ).get()
        
        guard let plaintext = String(data: decrypted, encoding: encoding) else {
            throw DecryptionError.decodingError
        }
        
        return plaintext
    }
    
}

