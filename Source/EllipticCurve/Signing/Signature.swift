//
//  Signature.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public typealias HexString = String
public struct Signature: Equatable, CustomStringConvertible {
    let r: Number
    let s: Number

    public init(r: Number, s: Number) {
        self.r = r
        self.s = s
    }

    public func toDER() -> String {
        return derEncode(r: r, s: s)
    }
}

public extension Signature {
    init?(hex: HexString) {
        guard
            hex.count == 128,
        case let rHex = String(hex.prefix(64)),
        case let sHex = String(hex.suffix(64)),
        let r = Number(hexString: rHex),
        let s = Number(hexString: sHex)
            else { return nil }
        self.init(r: r, s: s)
    }

    init(parts: SignatureParts) {
        self.init(r: parts.r, s: parts.s)
    }
}

public extension Signature {

    func asHexString() -> String {
        return [r, s].map { $0.asHexStringLength64() }.joined()
    }

    var description: String {
        return asHexString()
    }

    func asData() -> Data {
        return Data(hex: asHexString())
    }
}
