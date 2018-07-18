//
//  PerformanceSecp256r1Tests.swift
//  SwiftCryptoTests
//
//  Created by Alexander Cyon on 2018-07-17.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import XCTest
@testable import SwiftCrypto

class PerformanceSecp256r1Tests: XCTestCase {

    // 15 sec
    func testECMultiplication() {
        var expectedX: Number = 0
        var expectedY: Number = 0
        let privateKey = Number(hexString: "3D40F190DA0C18E94DB98EC34305113AAE7C51B51B6570A8FDDAA3A981CD69C3")!
//        self.measure {
            let publicKeyPoint = Secp256r1.G * privateKey
            expectedX = publicKeyPoint.x
            expectedY = publicKeyPoint.y
//        }
        XCTAssertEqual(expectedX, Number(hexString: "ED4AB8839C65C65A88F0F288ED9C443F9C5488323E61ED7DBB8EDF9BE6B1746D")!)
        XCTAssertEqual(expectedY, Number(hexString: "3E13BE2FFCB19403A761420B1D26AF55E265A6F924FE0B7174D4D3654249092F")!)
    }
}
