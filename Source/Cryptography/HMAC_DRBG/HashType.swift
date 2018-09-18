//
//  HashType.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-09-17.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import CryptoSwift

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
