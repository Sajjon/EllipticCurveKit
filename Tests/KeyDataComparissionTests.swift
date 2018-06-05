//
//  KeyDataComparissionTests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-06-05.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import XCTest
@testable import SwiftCrypto

class KeyDataTests: XCTestCase {
    func assertEqual(_ lhs: KeyData, _ rhs: KeyData, _ message: String = "") {
        XCTAssertEqual(lhs, rhs, message)
    }

    func assert(_ lhs: KeyData, greaterThan rhs: KeyData, _ message: String = "")  {
        XCTAssertGreaterThan(lhs, rhs, message)
    }

    func assert(_ lhs: KeyData, lessThanOrEqual rhs: KeyData, _ message: String = "")  {
        XCTAssertLessThanOrEqual(lhs, rhs)
    }

    func assert(_ lhs: KeyData, notGreaterThan rhs: KeyData, _ message: String = "")  {
        XCTAssertTrue(!(lhs > rhs))
    }

    func assert(_ lhs: KeyData, lessThan rhs: KeyData, _ message: String = "") {
        XCTAssertLessThan(lhs, rhs, message)
    }
}

class KeyDataComparissionTests: KeyDataTests {

    func testEqualEmpty() {
       assertEqual([], [], "Empty KeyData should be equal")
    }

    func testEqualSingleZero() {
        assertEqual([0], [0], "Single zero KeyData should be equal")
    }

    func testEqualThreeZero() {
        assertEqual([0, 0, 0], [0, 0, 0], "Three zeros KeyData should be equal")
    }

    func testEqualZerosDifferentLength() {
        let oneZero: KeyData = [0]
        let threeZeros: KeyData = [0, 0, 0]
        assertEqual(oneZero, threeZeros, "KeyData only containing zeros but different count should be equal")
        assertEqual(oneZero, KeyData([0]), "KeyData should not change after comparisson")
        XCTAssertEqual(oneZero.length, 1, "KeyData should not change after comparisson")
        assertEqual(threeZeros, [0, 0, 0], "KeyData should not change after comparisson")
        XCTAssertEqual(threeZeros.length, 3, "KeyData should not change after comparisson")
    }

    func testNotGreaterThan() {
        assert([0], notGreaterThan: [])
        assert([], notGreaterThan: [0])
    }

    func testGreaterThan() {
        assert([1], greaterThan: [])
        assert([1], greaterThan: [0])
        assert([3, 2, 1], greaterThan: [9, 8])
    }

    func testLessThan() {
        assert([0], lessThan: [1])
        assert([1], lessThan: [2])
        assert([9], lessThan: [1, 0])
        assert([1, 0, 1], lessThan: [1, 0, 2])
    }
}
