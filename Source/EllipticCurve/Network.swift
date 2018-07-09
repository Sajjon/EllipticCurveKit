//
//  Network.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

enum Network {
    case testnet
    case mainnet

    var pubkeyhash: Byte {
        switch self {
        case .mainnet: return 0x00
        case .testnet: return 0x6f
        }
    }

    var privateKeyWifPrefix: Byte {
        switch self {
        case .mainnet: return 0x80
        case .testnet: return 0xef
        }
    }

    var privateKeyWifSuffix: Byte {
        return 0x01
    }
}
