//
//  DataConvertible.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-09-17.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol NumberConvertible {
    var asNumber: Number { get }
}

func * (lhs: NumberConvertible, rhs: NumberConvertible) -> Number {
    return lhs.asNumber * rhs.asNumber
}
func * (lhs: NumberConvertible, rhs: Number) -> Number {
    return lhs.asNumber * rhs
}
func * (lhs: Number, rhs: NumberConvertible) -> Number {
    return lhs * rhs.asNumber
}
func + (lhs: NumberConvertible, rhs: NumberConvertible) -> Number {
    return lhs.asNumber + rhs.asNumber
}
func + (lhs: NumberConvertible, rhs: Number) -> Number {
    return lhs.asNumber + rhs
}
func + (lhs: Number, rhs: NumberConvertible) -> Number {
    return lhs + rhs.asNumber
}

public protocol DataConvertible: NumberConvertible {
    var asData: Data { get }
    var asHex: String { get }
//    init(data: Data)
}

extension Number {
    init(_ data: DataConvertible) {
        self.init(data: data.asData)
    }
}

extension Data {
    var byteCount: Int {
        return count
    }
}

extension NumberConvertible where Self: DataConvertible {
    public var asNumber: Number {
        return asData.toNumber()
    }
}

public extension DataConvertible {



    var byteCount: Int {
        return asData.byteCount
    }
    var bytes: [Byte] {
        return asData.bytes
    }

    var asHex: String {
        return asData.toHexString()
    }
}

func + (data: DataConvertible, byte: Byte) -> Data {
    return data.asData + Data([byte])
}

func + (lhs: Data, rhs: DataConvertible) -> Data {
    return Data(lhs.bytes + rhs.asData.bytes)
}

func + (lhs: DataConvertible, rhs: DataConvertible) -> Data {
    var bytes: [Byte] = lhs.bytes
    bytes.append(contentsOf: rhs.bytes)
    return Data(bytes)
}

func + (lhs: DataConvertible, rhs: DataConvertible?) -> Data {
    guard let rhs = rhs else { return lhs.asData }
    return lhs + rhs
}

func + (data: Data, byte: Byte) -> Data {
    return data + Data([byte])
}

func + (lhs: Data, rhs: Data?) -> Data {
    guard let rhs = rhs else { return lhs }
    return lhs + rhs
}

extension Data: ExpressibleByArrayLiteral {
    public init(arrayLiteral bytes: Byte...) {
        self.init(bytes)
    }
}

extension Array: NumberConvertible where Element == Byte {
    public var asNumber: Number {
        return asData.toNumber()
    }
}

extension Array: DataConvertible where Element == Byte {

    public var asData: Data { return Data(self) }
    public init(data: Data) {
        self.init(data.bytes)
    }
}

//extension Array: DataConvertible where Element == Byte {
//    public var asData: Data { return Data(self) }
//    public init(data: Data) {
//        self.init(data.bytes)
//    }
//}

extension Data: DataConvertible {
    public var asData: Data { return self }
    public init(data: Data) {
        self = data
    }
}

extension Byte: DataConvertible {
    public var asData: Data { return Data([self]) }
    public init(data: Data) {
        self = data.bytes.first ?? 0x00
    }
}

public extension BinaryInteger {
    var asData: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<Self>.size)
    }
}

extension Int8: DataConvertible {}

extension UInt16: DataConvertible {}
extension Int16: DataConvertible {}

extension UInt32: DataConvertible {}
extension Int32: DataConvertible {}

extension UInt64: DataConvertible {}
extension Int64: DataConvertible {}
