//
//  PrivateKey.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2018-07-09.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct PrivateKey<Curve: EllipticCurve> {

    public let number: Number

    public static func generateNew() -> PrivateKey {
        let byteCount = (Curve.order - 1).as256bitLongData().bytes.count
        var privateKey: PrivateKey!
        repeat {
            guard let randomBytes = try? securelyGenerateBytes(count: byteCount) else { continue }
            let randomNumber = Number(data: Data(bytes: randomBytes))
            privateKey = PrivateKey(number: randomNumber)
        } while privateKey == nil
        return privateKey
    }

    public init() {
        self = PrivateKey.generateNew()
    }

    public init?(number: Number) {
        guard case 1..<Curve.order = number else { return nil }
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

    func asHexStringLength64() -> String {
        return number.asHexStringLength64()
    }

    /// Uses `asHexStringLength64`
    func asHex() -> String {
        return asHexStringLength64()
    }

    func base64Encoded() -> String {
        return asData.base64EncodedString()
    }
}

extension PrivateKey: DataConvertible {
    public var asData: Data {
        return number.as256bitLongData()
    }

}
