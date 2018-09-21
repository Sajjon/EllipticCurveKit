//
//  Signature.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct Signature<Curve: EllipticCurve>: Equatable, CustomStringConvertible {
    let r: Number
    let s: Number

    /// `ensureLowSAccordingToBIP62` read below
    /// https://github.com/bitcoin/bips/blob/master/bip-0062.mediawiki#Low_S_values_in_signatures
    /// https://bitcoin.stackexchange.com/questions/38252/the-complement-of-s-when-s-curve-order-2
    /// https://bitcoin.stackexchange.com/questions/50980/test-r-s-values-for-signature-generation
    /// https://bitcointalk.org/index.php?topic=285142.msg3299061#msg3299061
    public init?(r: Number, s: Number, ensureLowSAccordingToBIP62: Bool = false) {
        guard r < Curve.P, s < Curve.N, r > 0, s > 0 else { return nil }
        self.r = r
        var s = s
        if ensureLowSAccordingToBIP62, s > (Curve.order-1)/2 {
            s = Curve.order - s
        }
        self.s = s
    }

    public func toDER() -> String {
        return derEncode(r: r, s: s)
    }
}

public extension Signature {
    public init?(hex: HexString) {
        guard
            hex.count == 128,
        case let rHex = String(hex.prefix(64)),
        case let sHex = String(hex.suffix(64)),
            sHex.count == 64 ,
        let r = Number(hexString: rHex),
        let s = Number(hexString: sHex)
            else { return nil }
        self.init(r: r, s: s)
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
