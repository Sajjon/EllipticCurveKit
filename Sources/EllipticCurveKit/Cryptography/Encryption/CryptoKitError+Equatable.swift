//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-03-09.
//

import CryptoKit

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

