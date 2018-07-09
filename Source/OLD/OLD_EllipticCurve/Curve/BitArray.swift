//
//  BitArray.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-01.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//  Found at: https://github.com/mauriciosantos/Buckets-Swift/blob/master/Source/BitArray.swift
//

import Foundation

public typealias Bit = Bool
public extension Bit {
    var isOne: Bool {
        return (self == true)
    }

    var isZero: Bool {
        return !isOne
    }

    static var zero: Bit {
        return false
    }

    static var one: Bit {
        return true
    }
}

public typealias Byte = UInt8

public func bitsToBytes(bits: [Bit]) -> [Byte] {
    assert(bits.count % 8 == 0, "Bit array size must be multiple of 8")

    let numBytes = 1 + (bits.count - 1) / 8
    var bytes = [Byte](repeating: 0, count: numBytes)

    for (index, bit) in bits.enumerated() {
        if bit.isOne {
            bytes[index / 8] += Byte(1 << (7 - index % 8))
        }
    }
    return bytes
}

public func bytesToBits(bytes: [Byte]) -> [Bit] {
    func bitsFrom(oneByte byte: Byte) -> [Bit] {
        var byte = byte
        var bits = [Bit](repeating: .zero, count: 8)
        for i in 0..<8 {
            let currentBit = byte & 0x01
            if currentBit != 0 {
                bits[i] = .one
            }

            byte >>= 1
        }

        return bits
    }
    let bits = bytes.flatMap { bitsFrom(oneByte: $0) }
    assert(bits.count % 8 == 0)
    return bits
}
