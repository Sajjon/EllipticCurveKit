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

public extension PublicKey: CustomStringConvertible {
    public var description: String {
        return publicKey
    }
}

private func derivePublicKey(from point: PublicKeyCurvePoint, formatted format: PublicKey.Format) -> String {
    switch format {
    case .uncompressed:
        let number = Number([Number.Word(4)] + point.x.words + point.y.words)
        return number.asHexString()
    case .compressed:
        let bit: Bit = point.y.magnitude[bitAt: 0] && true
        let prefix: Number.Word = bit ? 3 : 2
        let number = Number([prefix] + point.x.words)
        return number.asHexString()
    }
}
