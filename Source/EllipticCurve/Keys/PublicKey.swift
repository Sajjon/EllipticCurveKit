//
//  PublicKey.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public typealias HexString = String
public struct PublicKey {

    let point: Point
    let data: (uncompressed: Data, compressed: Data)
    let hex: (uncompressed: HexString, compressed: HexString)

    public init(point: Point) {
        let x = point.x
        let y = point.y
        let xData = x.asData()
        let yData = y.asData()

        let uncompressedPrefix = Data(0x04)
        let compresssedPrefix = Data(y.isEven ? 0x02 : 0x03)

        let uncompressed = [uncompressedPrefix, xData, yData]
        let compressed = [compresssedPrefix, xData]

        let uncompressedData: Data = uncompressed.reduce(.empty, +)
        let compressedData: Data = compressed.reduce(.empty, +)

        let uncompressedHex = uncompressed.map { $0.toHexString() }.joined().uppercased()
        let compressedHex = compressed.map { $0.toHexString() }.joined().uppercased()

        assert(uncompressedHex.count == 130)
        assert(compressedHex.count == 66)

        self.point = point
        self.data = (uncompressed: uncompressedData, compressed: compressedData)
        self.hex = (uncompressed: uncompressedHex, compressed: compressedHex)

    }
}

public extension PublicKey {
    public init(privateKey: PrivateKey) {
        let point = G * privateKey.number
        self.init(point: point)
    }
}

public extension PublicKey {
    var x: Number {
        return point.x
    }

    var y: Number {
        return point.y
    }
}
