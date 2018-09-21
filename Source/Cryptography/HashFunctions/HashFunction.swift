//
//  HashFunction.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-09-21.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public enum HashFunction: String {
    case sha256
}

public extension HashFunction {

    init?(name: String) {
        guard let hash = HashFunction(rawValue: name.lowercased()) else { return nil }
        self = hash
    }

    /// Length of digest in bits
    var digestLengthInBits: Int {
        switch self {
        case .sha256: return 256
        }
    }

    /// Length of digest in bytes
    var digestLength: Int {
        return byteCount(fromBitCount: digestLengthInBits)
    }
}
