//
//  DataToStringBackToDataTests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-06-10.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//


import XCTest
import BigInt

@testable import SwiftCrypto

class DataToStringBackToDataTests: XCTestCase {

    func testSingleElementInt64MaxVal() {
        let array = [UInt.max]
        XCTAssertEqual(
            KeyData(msbZeroIndexed: array),
            KeyData(msbZeroIndexed: KeyData(msbZeroIndexed: array).asHexString())
        )
    }

    func testSingleElementMSBZeroOne() {
        let msbZeroIndexed: [UInt] = [0, 1]
        XCTAssertEqual(
            KeyData(msbZeroIndexed: msbZeroIndexed),
            KeyData(msbZeroIndexed: KeyData(msbZeroIndexed: msbZeroIndexed).asHexString())
        )
    }
}
