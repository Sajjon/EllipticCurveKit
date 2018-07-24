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

    public init(message: String) {
        func hash256(for message: String) -> Data {
            return Crypto.sha2Sha256(message.data(using: .utf8, allowLossyConversion: false)!)
        }
        self.hexString = hash256(for: message).toHexString()
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
