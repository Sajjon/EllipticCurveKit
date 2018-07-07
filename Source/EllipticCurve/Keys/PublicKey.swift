//
//  PublicKey.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-06-15.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct PublicKeyCurvePoint {

    public init(_ privateKey: PrivateKey) {
        let curve = privateKey.curve
        let d = privateKey
        let Q: AnyEllipticCurveOverFiniteField = curve * d
        let normalizedQ = Q.normalized()
        let x = normalizedQ.G.x // 32 bytes?
        let y = normalizedQ.G.y // 32 bytes?
        self.init(x: x, y: y)
    }

    public let x: Number
    public let y: Number

    public static let bitWidth: Int = 256

    public init(x: Number, y: Number) {
        guard
            x.bitWidth == PublicKeyCurvePoint.bitWidth,
            y.bitWidth == PublicKeyCurvePoint.bitWidth
        else { fatalError() }
        self.x = x
        self.y = y
    }
//
//    init<C>(privateKey: PrivateKey, curve: C) where C: EllipticCurveOverFiniteField {
//        let Q = privateKey
//            /**
//                Find the bitcoin address from the public key self.Q
//                We do normalization to go from the projective coordinates to the usual
//                (x,y) coordinates.
//            */
//            Q.Normalize()
//
//            x = Int2Byte(Q.x[0], 32)
//            y = Int2Byte(Q.x[1], 32)
//
//    }
}

public struct PublicKey {

    public enum Format {
        case compressed
        case uncompressed

        public var prefixByte: UInt8 {
            switch self {
            case .uncompressed: return 0x4
            case .compressed: return 0x2
            }
        }
    }
    
//    public let publicKey: [UInt8]
    public let point: PublicKeyCurvePoint
    public let publicKey: String
    public let format: Format
    public let curve: AnyEllipticCurveOverFiniteField

    public init(privateKey: PrivateKey, format: Format = .uncompressed) {
        self.curve = privateKey.curve
        self.point = PublicKeyCurvePoint(privateKey)
        self.format = format
        self.publicKey = derivePublicKey(from: point, formatted: format)
    }
}

extension PublicKey: CustomStringConvertible {
    public var description: String {
        return publicKey
    }
}

private func derivePublicKey(from point: PublicKeyCurvePoint, formatted format: PublicKey.Format) -> String {
    let pk_x = point.x
    let pk_y = point.y

//    pkx_bytes = int(binascii.hexlify(pk_x), 16)
//    pky_bytes = int(binascii.hexlify(pk_y), 16)

//    uncompressed = chr(4) + pk_x + pk_y
//    compressed =  chr(2 + (pky_bytes & 1)) + pk_x

    switch format {
    case .uncompressed:
        return Number([Number.Word(4)] + pk_x.words + pk_y.words).asHexString()
    case .compressed:
        fatalError() // chr(2 + (pky_bytes & 1)) + pk_x
    }
}
