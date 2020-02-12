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
        performTests(file: "hmac_drbg_nist_no-resistance_no-reseed_no-additional-data")
    }

    func testVectorsNoReseedWithAdditionalData() {
        performTests(file: "hmac_drbg_nist_no-resistance_no-reseed_with-additional-data")
    }

}

// Helpers

private extension HMAC_DRBG_Tests {
    func hmacTests(from file: String) -> TestJSON {
        do {
            return try testData(bundleType: self, jsonName: file)
        } catch {
            fatalError("Failed to access file: '\(file)', error: \(error)")
        }
    }

    func perform(
        test vector: TestVector,
        with configuration: HMACTestConfiguration,
        line: UInt
    ) {
        print("Test coniguration: \n`\(configuration)`")

        perform(
            test: vector,
//            hmac: configuration.hmac,
            resultByteCount: configuration.expectedResultByteLength,
            line: line
        )
    }

    func perform(
        test vector: TestVector,
        resultByteCount: Int,
        line: UInt
    ) {
        print("Test Vector: \n`\(vector)`")

        perform(
//            hmac: hmac,
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
            expectedResult: vector.expected,
            line: line
        )
    }

    func perform(testVectorString: TestVectorStrings, resultByteCount: Int, line: UInt) {
        perform(test: testVectorString.asTestVector(), resultByteCount: resultByteCount, line: line)
    }


    func perform(
//        hmac: HMAC,
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
        expectedResult: Data,
        line: UInt
    ) {

        let drbg = HMAC_DRBG(
//            hmac: hmac,
            entropy: entropy,
            nonce: nonce,
            personalization: pers
        )


        let generated1 = try! drbg.generateNumberOfLength(byteCountResult, additionalData: generateCalls[0].additionalData)

        XCTAssertEqual(generated1.state.v, generateCalls[0].state.value, line: line)
        XCTAssertEqual(generated1.state.key, generateCalls[0].state.key, line: line)

        let generated2 = try! drbg.generateNumberOfLength(byteCountResult, additionalData: generateCalls[1].additionalData)

        XCTAssertEqual(generated2.state.v, generateCalls[1].state.value, line: line)
        XCTAssertEqual(generated2.state.key, generateCalls[1].state.key, line: line)

        XCTAssertEqual(generated2.result.asHex, expectedResult.asHex, line: line)
    }

    func performTests(file: String, line: UInt = #line) {
        let tests = hmacTests(from: file)
        let configuration = tests.configuration.asConfiguration()
        print("Config: \n`\(configuration)`\n")
        tests.vectors.map { $0.asTestVector() }.forEach {
            perform(test: $0, with: configuration, line: line)
        }
    }
}
