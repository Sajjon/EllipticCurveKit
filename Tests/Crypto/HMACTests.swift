//
//  HMACTests.swift
//  EllipticCurveKitTests
//
//  Created by Alexander Cyon on 2018-09-16.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import XCTest
@testable import EllipticCurveKit
import CryptoSwift


class HMACRFC4231Tests: XCTestCase {

    private func performHmacTest(key: Data, data: String, expectedHexDigest: String, hash: HashType = .sha2sha256) {
        let h = HMACUpdatable(key: key, data: data, hash: hash)
        XCTAssertEqual(h.hexDigest(), expectedHexDigest)
    }

    private func performHmacTest(key: String, data: String, expectedHexDigest: String, hash: HashType = .sha2sha256) {
        performHmacTest(key: key.data(using: .utf8)!, data: data, expectedHexDigest: expectedHexDigest, hash: hash)
    }

    // 4.3.  Test Case 2
    func test4_3_2() {
        performHmacTest(key: "Jefe", data: "what do ya want for nothing?", expectedHexDigest: "5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843")
    }
}
