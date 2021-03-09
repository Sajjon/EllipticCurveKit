//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-03-09.
//

import CryptoKit

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
}
