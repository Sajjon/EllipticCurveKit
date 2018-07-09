//
//  Signature.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

struct Signature {
    let data: Data

    init?(data: Data) {
        guard data.bytes.count == 64 else { return nil }
        self.data = data
    }
}

extension Signature {
    init?(number: Number) {
        self.init(data: number.asData())
    }
}
