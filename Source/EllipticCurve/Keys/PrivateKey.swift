//
//  PrivateKey.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

struct PrivateKey {
    let number: Number

    init(number: Number) {
        self.number = number
    }
}

extension PrivateKey {
    init(base64: Data) {
        self.init(number: Number(data: base64))
    }

    init?(base64: String) {
        guard let data = Data(base64Encoded: base64) else { return nil }
        self.init(base64: data)
    }

    init?(hex: String) {
        guard let number = Number(hexString: hex) else { return nil }
        self.init(number: number)
    }
}

extension PrivateKey {
    func base64Encoded() -> String {
        return number.asData().base64EncodedString()
    }
}
