//
//  PythonModulusTests.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-08.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

private func _bigMod(_ a: BigInt, _ b: BigInt) -> BigInt {
    //        return a.modulus(b)
    return pythonMod(a, b)
}

private func bigMod(_ a: Int, _ b: Int) -> Int {
    let modulus = _bigMod(BigInt(a), BigInt(b))
    return Int(modulus.asDecimalString())!
}

private func assertModSame(_ a: Int, _ b: Int) {
    //        XCTAssertEqual(bigMod(a, b), (a % b))
    XCTAssertEqual(bigMod(a, b), pythonMod(a, b))
}

func testAssertBigIntPythonMod() {
    for a in 1...100 {
        for n in 1...100 {
            assertModSame(a, n)
        }
    }
}
