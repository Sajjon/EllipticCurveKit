//
//  PrivateKey.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct PrivateKey<Curve: EllipticCurve> {
    public enum Format {
        case raw
        indirect case wif(WIF)
        public enum WIF {
            case uncompressed(PrivateKeyWIF<Curve>)
            case compressed(PrivateKeyWIF<Curve>)
        }
    }
    
    let number: Number

    public init?(number: Number) {
        guard case 1..<Curve.N = number else { return nil }
        self.number = number
    }
}

public extension PrivateKey {
    public init?(base64: Data) {
        self.init(number: Number(data: base64))
    }

    public init?(base64: String) {
        guard let data = Data(base64Encoded: base64) else { return nil }
        self.init(base64: data)
    }

    public init?(hex: String) {
        guard let number = Number(hexString: hex) else { return nil }
        self.init(number: number)
    }
}

public extension PrivateKey {

    func asData() -> Data {
        return number.asData()
    }

    func base64Encoded() -> String {
        return asData().base64EncodedString()
    }
}
