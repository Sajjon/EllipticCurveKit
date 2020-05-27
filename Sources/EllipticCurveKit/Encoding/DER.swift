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

public func derDecode(data: Data) -> (r: Number, s: Number)? {
    guard
        data.count > 8,
        data[0] == DERCode.SEQUENCE.rawValue,
        data[1] == data.count - 2,
        data[2] == DERCode.INTEGER.rawValue
    else {
        return nil
    }
    
    let rLen = Int(data[3])
    let rIndex = 4
    let rData = data[rIndex..<rIndex+rLen].suffix(32)
    
    guard rData.count == 32 else { return nil }
    
    let r = Number([0] + rData)
    
    guard data[rLen+4] == DERCode.INTEGER.rawValue else { return nil }
    
    let sLen = Int(data[rLen+5])
    let sIndex = rLen+6
    let sData = data[sIndex..<sIndex+sLen].suffix(32)
    
    guard sData.count == 32 else { return nil }
    
    let s = Number([0] + sData)
    
    return (r, s)
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
