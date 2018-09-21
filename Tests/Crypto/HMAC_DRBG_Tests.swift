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
        print("Test Vector: \n`\(vector)`")

        let hmac = HMAC_DRBG(
            hasher: configuration.hasher,
            entropy: vector.entropy,
            nonce: vector.nonce,
            personalization: vector.personalizationString
        )


        let generated1 = try! hmac.generateNumberOfLength(
            configuration.expectedResultByteLength,
            additionalData: s2d(o: vector.generateCalls[0].additionalInput)
        )

        XCTAssertEqual(generated1.state.v, vector.generateCalls[0].keyValue.v)
        XCTAssertEqual(generated1.state.key, vector.generateCalls[0].keyValue.key)

        let generated2 = try! hmac.generateNumberOfLength(configuration.expectedResultByteLength,
            additionalData: s2d(o: vector.generateCalls[1].additionalInput)
        )
        print(generated2)
        XCTAssertEqual(generated2.state.v, vector.generateCalls[1].keyValue.v)
        XCTAssertEqual(generated2.state.key, vector.generateCalls[1].keyValue.key)

        XCTAssertEqual(generated2.result.asHex, vector.expected.asHex)
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
