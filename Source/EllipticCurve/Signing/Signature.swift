//
//  Signature.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct Signature: Equatable, CustomStringConvertible {
    let hexString: HexString

    public init(hex: HexString) {
        self.hexString = hex
        assert(hex.count % 2 == 0)
    }
}

public extension Signature {
    public init(number: Number) {
        self.init(hex: number.asHexString())
    }

    public init(data: Data) {
        self.init(hex: data.toHexString())
    }

    var description: String {
        return hexString
    }
}
