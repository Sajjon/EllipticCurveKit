//
//  TestJSON.swift
//  EllipticCurveKitTests
//
//  Created by Alexander Cyon on 2018-09-17.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
@testable import EllipticCurveKit
struct TestJSON: Codable {
    let configuration: HMACTestConfigurationRaw
    let vectors: [TestVectorStrings]
}

struct Generate: Codable {
    enum CodingKeys: String, CodingKey {
        case keyValue = "KVAfterGenerate"
        case additionalInput = "AdditionalInputForGenerate"
    }
    let keyValue: KeyValue
    let additionalInput: String?
}

struct HMACTestConfigurationRaw: Codable {
    enum CodingKeys: String, CodingKey {
        case isPredictionResistance = "PredictionResistance"
        case entropyInputBitLength = "EntropyInputLen"
        case nonceBitLength = "NonceLen"
        case personalizationStringBitLength = "PersonalizationStringLen"
        case additionalInputBitLength = "AdditionalInputLen"
        case expectedResultBitLength = "ReturnedBitsLen"

        case hashFunction, zipDownloadURL, filePathInZip
    }

    let hashFunction: String
    let zipDownloadURL: URL
    let filePathInZip: URL
    let isPredictionResistance: Bool
    let entropyInputBitLength: Int
    let nonceBitLength: Int
    let personalizationStringBitLength: Int
    let additionalInputBitLength: Int
    let expectedResultBitLength: Int

}

struct HMACTestConfiguration {
    let hmac: HMAC
    let zipDownloadURL: URL
    let filePathInZip: URL
    let isPredictionResistance: Bool
    let entropyInputByteLength: Int
    let nonceByteLength: Int
    let personalizationStringByteLength: Int
    let additionalInputByteLength: Int
    let expectedResultByteLength: Int
}

extension HMACTestConfiguration: CustomStringConvertible {
    var description: String {
        return """
        vector test suite: \(filePathInZip)
        nonce byte length: \(nonceByteLength)
        expected byte length: \(expectedResultByteLength)
        """
    }
}


extension HMACTestConfigurationRaw {
    func asConfiguration() -> HMACTestConfiguration {
        return HMACTestConfiguration(
            hmac: DefaultHMAC(name: hashFunction)!,
            zipDownloadURL: zipDownloadURL,
            filePathInZip: filePathInZip,
            isPredictionResistance: isPredictionResistance,
            entropyInputByteLength: entropyInputBitLength / 8,
            nonceByteLength: nonceBitLength / 8,
            personalizationStringByteLength: personalizationStringBitLength / 8,
            additionalInputByteLength: additionalInputBitLength / 8,
            expectedResultByteLength: expectedResultBitLength / 8
        )
    }
}

