//
//  DataConvertible.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-09-17.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol DataConvertible {
    var asData: Data { get }
    var asHex: String { get }
    init(data: Data)
}

extension DataConvertible {
    public var asHex: String {
        return asData.toHexString()
    }
}

func + (data: DataConvertible, byte: Byte) -> Data {
    return data.asData + Data([byte])
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
        self.init(bytes: bytes)
    }
}

extension Array: DataConvertible where Element == Byte {
    public var asData: Data { return Data(self) }
    public init(data: Data) {
        self.init(data.bytes)
    }
}

extension Data: DataConvertible {
    public var asData: Data { return self }
    public init(data: Data) {
        self = data
    }
}
