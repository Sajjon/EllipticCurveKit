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

class HMAC_DRBG_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testVectorsNoReseedNoAdditionalData() {
        performTests(file: "no_additional_data")
    }

    func testVectorsNoReseedWithAdditionalData() {
        performTests(file: "additional_data")
    }

    /*
     [SHA-1]
     [PredictionResistance = False]
     [EntropyInputLen = 128]
     [NonceLen = 64]
     [PersonalizationStringLen = 0]
     [AdditionalInputLen = 0]
     [ReturnedBitsLen = 640]
    */
    func testSHA1() {
//        let vector = TestVectorStrings(
//            name: "Count 0",
//            entropy: "e91b63309e93d1d08e30e8d556906875",
//            nonce: "f59747c468b0d0da",
//            gen1V: "0e28fe04dd16482f8e4b048675318adcd5e6e6cf",
//            gen1K: "764d4f1fb7b04624bcb14642acb24d70eff3c0c8",
//            gen2V: "749a95f0882e0179d66d8ae2697802f8f568ce2f",
//            gen2K: "bfcd86fcb4c2efce22f6e9b69742751a17b0056c",
//            expected: "b7928f9503a417110788f9d0c2585f8aee6fb73b220a626b3ab9825b7a9facc79723d7e1ba9255e40e65c249b6082a7bc5e3f129d3d8f69b04ed1183419d6c4f2a13b304d2c5743f41c8b0ee73225347"
//        )
//
//        perform(testVectorString: vector, hmac: UpdatableHashProvider.hmac(variant: .sha2sha256), resultByteCount: 640/8)
    }
}

// Helpers
private extension HMAC_DRBG_Tests {
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

    private func perform(test vector: TestVector, with configuration: HMACTestConfiguration) {
        print("Test coniguration: \n`\(configuration)`")

        perform(test: vector, hmac: configuration.hmac, resultByteCount: configuration.expectedResultByteLength)
    }

    private func perform(test vector: TestVector, hmac: HMAC, resultByteCount: Int) {
        print("Test Vector: \n`\(vector)`")

        perform(
            hmac: hmac,
            entropy: vector.entropy,
            nonce: vector.nonce,
            pers: vector.personalizationString,
            byteCountResult: resultByteCount,
            generateCalls: vector.generateCalls.map {
                (
                    additionalData: s2d(o: $0.additionalInput),
                    state: (value: $0.keyValue.v, key: $0.keyValue.key)
                )
            },
            expectedResult: vector.expected
        )
    }

    private func perform(testVectorString: TestVectorStrings, hmac: HMAC, resultByteCount: Int) {
        perform(test: testVectorString.asTestVector(), hmac: hmac, resultByteCount: resultByteCount)
    }


    private func perform(
        hmac: HMAC,
        entropy: Data,
        nonce: Data,
        pers: Data?,
        byteCountResult: Int,
        generateCalls: [(
            additionalData: Data?,
            state: (
                value: String,
                key: String
            )
        )],
        expectedResult: Data
        ) {

        let drbg = HMAC_DRBG(
            hmac: hmac,
            entropy: entropy,
            nonce: nonce,
            personalization: pers
        )


        let generated1 = try! drbg.generateNumberOfLength(byteCountResult, additionalData: generateCalls[0].additionalData)

        XCTAssertEqual(generated1.state.v, generateCalls[0].state.value)
        XCTAssertEqual(generated1.state.key, generateCalls[0].state.key)

        let generated2 = try! drbg.generateNumberOfLength(byteCountResult, additionalData: generateCalls[1].additionalData)

        XCTAssertEqual(generated2.state.v, generateCalls[1].state.value)
        XCTAssertEqual(generated2.state.key, generateCalls[1].state.key)

        XCTAssertEqual(generated2.result.asHex, expectedResult.asHex)
    }

    private func performTests(file: String) {
        let tests = hmacTests(from: file)
        let configuration = tests.configuration.asConfiguration()
        print("Config: \n`\(configuration)`\n")
        tests.vectors.map { $0.asTestVector() }.forEach {
            perform(test: $0, with: configuration)
        }
    }
}
