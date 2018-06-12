//
//  ToDecimalStringTests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-06-11.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import Foundation
import XCTest
@testable import SwiftCrypto

class ToDecimalStringTests: KeyDataConvertibleTests {

    func testDescriptionRadix10() {
        let data: KeyData = [1, 0]
        let expected = "18446744073709551616"
        XCTAssertEqual(data.description, expected)
        XCTAssertEqual(data.toString(radix: 10), data.description)

        XCTAssertEqual(
            KeyData(msbZeroIndexed: [1, 1]).description,
            "18446744073709551617"
        )

        XCTAssertEqual(
            KeyData(msbZeroIndexed: [1, 2]).description,
            "18446744073709551618"
        )

        XCTAssertEqual(
            KeyData(msbZeroIndexed: [1, 10]).description,
            "18446744073709551626"
        )

        XCTAssertEqual(
            KeyData(msbZeroIndexed: [2, 0]).description,
            "36893488147419103232"
        )

        XCTAssertEqual(
            KeyData(msbZeroIndexed: [10, 0]).description,
            "184467440737095516160"
        )

        XCTAssertEqual(
            KeyData(msbZeroIndexed: [10, 1]).description,
            "184467440737095516161"
        )

        XCTAssertEqual(
            KeyData(msbZeroIndexed: [10, 10]).description,
            "184467440737095516170"
        )
    }

}
