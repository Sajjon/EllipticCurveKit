//
//  Message.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

struct Message {
    let data: Data

    init(data: Data) {
        self.data = data
    }
}

extension Message {
    init(number: Number) {
        self.init(data: number.asData())
    }
}
