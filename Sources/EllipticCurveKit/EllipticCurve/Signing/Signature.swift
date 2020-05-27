//
//  Signature.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct Signature<Curve: EllipticCurve>: Equatable, CustomStringConvertible {
    public let r: Number
    public let s: Number
    
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
    
    public init?(der: Data, ensureLowSAccordingToBIP62: Bool = false) {
        guard let (r, s) = derDecode(data: der) else { return nil }
        self.init(r: r, s: s, ensureLowSAccordingToBIP62: ensureLowSAccordingToBIP62)
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

public extension Data {
    init(hex: String) {
        self.init(Array<UInt8>(hex: hex))
    }
    
    var bytes: Array<UInt8> {
        Array(self)
    }
    
    func toHexString() -> String {
        self.bytes.toHexString()
    }
}

extension Array {
    init(reserveCapacity: Int) {
        self = Array<Element>()
        self.reserveCapacity(reserveCapacity)
    }
    
    var slice: ArraySlice<Element> {
        self[self.startIndex ..< self.endIndex]
    }
}

extension Array where Element == UInt8 {
    public init(hex: String) {
        self.init(reserveCapacity: hex.unicodeScalars.lazy.underestimatedCount)
        var buffer: UInt8?
        var skip = hex.hasPrefix("0x") ? 2 : 0
        for char in hex.unicodeScalars.lazy {
            guard skip == 0 else {
                skip -= 1
                continue
            }
            guard char.value >= 48 && char.value <= 102 else {
                removeAll()
                return
            }
            let v: UInt8
            let c: UInt8 = UInt8(char.value)
            switch c {
            case let c where c <= 57:
                v = c - 48
            case let c where c >= 65 && c <= 70:
                v = c - 55
            case let c where c >= 97:
                v = c - 87
            default:
                removeAll()
                return
            }
            if let b = buffer {
                append(b << 4 | v)
                buffer = nil
            } else {
                buffer = v
            }
        }
        if let b = buffer {
            append(b)
        }
    }
    
    public func toHexString() -> String {
        `lazy`.reduce(into: "") {
            var s = String($1, radix: 16)
            if s.count == 1 {
                s = "0" + s
            }
            $0 += s
        }
    }
}


//extension Array where Element == Byte {
//    func toHexString() -> String {
//        fatalError()
//    }
//}

extension String: DataConvertible {
    public var asData: Data {
//        fatalError()
        data(using: .utf8)!
    }
    
    
}
