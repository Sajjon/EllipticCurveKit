//
//  DEREncode.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-22.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public func derEncode(r: Number, s: Number) -> String {
    func encode(_ number: Number) -> String {

        let numberBytes = number.asTrimmedData().bytes

        var bytes: [Byte]

        if numberBytes[0] > 0x7f {
            bytes = [0x0] + numberBytes
        } else {
            bytes = numberBytes
        }

        return DERCode.INTEGER.hex + bytes.count.evenNumberedHexStringChars + bytes.toHexString()
    }

    let encodedR = encode(r)
    let encodedS = encode(s)

    let encoded: String = encodedR + encodedS

    let numberOfHexCharsPerByte = 2
    let byteCount = encoded.count/numberOfHexCharsPerByte

    return DERCode.SEQUENCE.hex + byteCount.evenNumberedHexStringChars + encoded
}

private extension Int {
    var evenNumberedHexStringChars: String {
        return String(format:"%02x", self)
    }
}

private enum DERCode: Byte {

    case SEQUENCE = 0x30
    case INTEGER = 0x02
}

private extension DERCode {
    var hex: String {
        return Int(rawValue).evenNumberedHexStringChars
    }
}
