//
//  EquationTests.swift
//  EllipticCurveKitTests
//
//  Created by Alexander Cyon on 2018-08-31.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import XCTest
import EquationKit
import BigInt

@testable import EllipticCurveKit

class EquationTests: XCTestCase {
    func testSimpleEquation() {
        let eq = 𝑥⁴*𝑦 - 5*𝑦³*𝑥 - 𝑥³
        XCTAssertEqual(eq.evaluate() {[ 𝑥 <- 3, 𝑦 <- 2 ]}, 15)
        XCTAssertEqual(eq.differentiateWithRespectTo(𝑥)?.evaluate() {[ 𝑥 <- 4, 𝑦 <- 7 ]}, 29)
        XCTAssertEqual(eq.differentiateWithRespectTo(𝑦)?.evaluate() {[ 𝑥 <- 4, 𝑦 <- 2 ]}, 16)
    }

    // Using a montgomery
    func testBigNumberEquation() {

        // a, b values of secp256r1
        let a = BigInt(hexString: "0xFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFC")!
        let b = BigInt(hexString: "0x5AC635D8AA3A93E7B3EBBD55769886BC651D06B0CC53B0F63BCE3C3E27D2604B")!

        let shortWeierstrassEquation = 𝑦² - 𝑥³ + a*𝑥 + b
        let secp256r1GeneratorPoint = AnyTwoDimensionalPoint(
            x: BigInt(hexString: "0x6B17D1F2E12C4247F8BCE6E563A440F277037D812DEB33A0F4A13945D898C296")!,
            y: BigInt(hexString: "0x4FE342E2FE1A7F9B8EE7EB4A7C0F9E162BCE33576B315ECECBB6406837BF51F5")!
        )
        /*
         Python

         a = int('0xFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFC', 16)
         b = int('0x5AC635D8AA3A93E7B3EBBD55769886BC651D06B0CC53B0F63BCE3C3E27D2604B', 16)
         x = int('0x6B17D1F2E12C4247F8BCE6E563A440F277037D812DEB33A0F4A13945D898C296', 16)
         y = int('0x4FE342E2FE1A7F9B8EE7EB4A7C0F9E162BCE33576B315ECECBB6406837BF51F5', 16)
         evaluation = y**2 - x**3 + a*x + b
         print(hex(evaluation)) // NEGATIVE 0x12bdd1ad1121f686cbad68da88e7241cba2f01d878693d960b5df51a2dc06312494c29003a45e19d45779275e9ed2fda0746a448307a1baae78da4d1b094861a0b5fd3490eb08898bb6159dda9fdc931a9fb9683271e0c002b41d1c939e98d2c

         */
        XCTAssertEqual(shortWeierstrassEquation.evaluate() {[ 𝑥 <- secp256r1GeneratorPoint.x, 𝑦 <- secp256r1GeneratorPoint.y ]}, BigInt(hexString: "0x12bdd1ad1121f686cbad68da88e7241cba2f01d878693d960b5df51a2dc06312494c29003a45e19d45779275e9ed2fda0746a448307a1baae78da4d1b094861a0b5fd3490eb08898bb6159dda9fdc931a9fb9683271e0c002b41d1c939e98d2c")!.negated())
    }
}
