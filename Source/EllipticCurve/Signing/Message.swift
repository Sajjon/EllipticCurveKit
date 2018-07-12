//
//  Message.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct Message: Equatable, CustomStringConvertible {
    private let hexString: HexString

    public init(hex: HexString) {
        self.hexString = hex
    }
}

public extension Message {

    var description: String {
        return hexString
    }

    public init(number: Number) {
        self.init(hex: number.asHexString())
    }

    public init(data: Data) {
        self.init(hex: data.toHexString())
    }

    func asData() -> Data {
        return Data(hex: hexString)
    }
}
