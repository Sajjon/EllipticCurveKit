//
//  HMAC_DRBG_Tests.swift
//  EllipticCurveKitTests
//
//  Created by Alexander Cyon on 2018-09-15.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import XCTest
@testable import EllipticCurveKit

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
    let hasher: UpdatableHasher
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
//    var hasher: UpdatableHasher
    func asConfiguration() -> HMACTestConfiguration {
        return HMACTestConfiguration(
            hasher: { () -> UpdatableHasher in
                switch hashFunction {
                case "sha256": return UpdatableHashProvider.hasher(variant: .sha2sha256)
                default: fatalError("incorrect implementation")
                }
        }(),
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

struct TestJSON: Codable {
    let configuration: HMACTestConfigurationRaw
    let vectors: [TestVectorStrings]
}

struct TestVectorStrings: Codable {
    enum CodingKeys: String, CodingKey {
        case name = "Count"
        case entropy = "EntropyInput"
        case nonce = "Nonce"
        case personalizationString = "PersonalizationString"
        case entropyInputReseed = "EntropyInputReseed"
        case additionalInputReseed = "AdditionalInputReseed"
        case additionalInputInit = "AdditionalInput1"
        case additionalInputGenerate = "AdditionalInput2"
        case expected = "ReturnedBits"
    }

    let name: String
    let entropy: String
    let nonce: String
    let personalizationString: String?
    let entropyInputReseed: String?
    let additionalInputReseed: String?
    let additionalInputInit: String?
    let additionalInputGenerate: String?
    let expected: String
}


struct TestVector {
    let name: String
    let entropy: Data
    let nonce: Data
    let personalizationString: Data?
    let entropyInputReseed: Data?
    let additionalInputReseed: Data?
    let additionalInputInit: Data?
    let additionalInputGenerate: Data?
    let expected: Number
}



extension TestVectorStrings {
    func asTestVector() -> TestVector {

        func s2d(_ string: String) -> Data {
            return Number(hexString: string)!.asTrimmedData()
        }

        func s2d(o string: String?) -> Data? {
            guard let string = string else { return nil }
            return s2d(string)
        }

        return TestVector(
            name: name,
            entropy: s2d(entropy),
            nonce: s2d(nonce),
            personalizationString: s2d(o: personalizationString),
            entropyInputReseed: s2d(o: entropyInputReseed),
            additionalInputReseed: s2d(o: entropyInputReseed),
            additionalInputInit: s2d(o: additionalInputInit),
            additionalInputGenerate: s2d(o: additionalInputGenerate),
            expected: Number(hexString: expected)!
        )
    }
}

class HMAC_DRBG_Tests: XCTestCase {

    private func hmacTests(from file: String) -> TestJSON {
        let t = type(of: self)
        let bundle = Bundle(for: t.self)
        if let path = bundle.path(forResource: file, ofType: "json") {
            print("found path: `\(path)`")
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                return try JSONDecoder().decode(TestJSON.self, from: data)
            } catch {
                XCTFail("Failed to parse JSON, error: \(error)")
            }
        } else {
            XCTFail("no path")
        }
        fatalError("incorrect implementation")
    }

    func perform(test vector: TestVector, with configuration: HMACTestConfiguration) {
        print("Test Vector: \n`\(vector)`")

        let hmac = HMAC_DRBG(
            hasher: configuration.hasher,
            entropy: vector.entropy,
            nonce: vector.nonce,
            personalization: vector.personalizationString
        )

        let generatedNumber = hmac.generateNumberOf(
            length: configuration.expectedResultByteLength,
            additionalData: vector.additionalInputGenerate
        )

        XCTAssertEqual(generatedNumber, vector.expected)
    }

    private func performTests(file: String) {
        let tests = hmacTests(from: file)
        let configuration = tests.configuration.asConfiguration()
        print("Config: \n`\(configuration)`\n")
        tests.vectors.map { $0.asTestVector() }.forEach {
            perform(test: $0, with: configuration)
        }
    }

    func testReseedAdditionalDataVectors() {
        performTests(file: "additional_data")
    }
}
extension TestVector: CustomStringConvertible {
    var description: String {
        return """
        name: \(name)
        entropy: \(entropy.toHexString())
        nonce: \(nonce.toHexString())
        pers: \(String(describing: personalizationString?.toHexString()))
        """
    }
}
