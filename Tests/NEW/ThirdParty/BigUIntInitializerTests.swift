//
//  BigUIntInitializerTests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-06-10.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import XCTest
import BigInt

@testable import SwiftCrypto

class BigUIntInitializerTests: XCTestCase {

    func testDesignatedInitBehavesLikeProtocolDesignatedInit() {
        var array: [BigUInt.Element] = []

        array = [0, 0, 1, 2, 0]
        XCTAssertEqual(BigUInt(words: array), BigUInt(lsbZeroIndexed: array), "Only trailing zeros should be removed")

        array = [0]
        XCTAssertEqual(BigUInt(words: array), BigUInt(lsbZeroIndexed: array), "Only zero should be removed")

        array = [1, 2, 3]
        XCTAssertEqual(BigUInt(words: array), BigUInt(lsbZeroIndexed: array), "Only non zero should be same")

    }

}
