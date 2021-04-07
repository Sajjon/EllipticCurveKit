//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-03-09.
//

import CryptoKit
import Foundation

// MARK: SealedBox
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


public extension ECIES.SealedBox {

    
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
    
    /// The combined representation `(nonce || ephemeralPublicKeyCompressed || tag || ciphertext)`
    var combined: Data {
        var combined = Data(nonce)
        combined.append(ephemeralPublicKey.data.compressed)
        combined.append(tag)
        combined.append(ciphertext)
        return combined
    }
    
}
