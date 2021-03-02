//
//  ModularSquareRootsTests.swift
//  EllipticCurveKitTests
//
//  Created by Alexander Cyon on 2018-07-30.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import XCTest

@testable import EllipticCurveKit

class ModularSquareRootsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = true
    }
    
    private func _testAllSquareRoots(_ p: Number) {
        
        var allSquares = Set<[Number]>()
        var notSquares = Set<Number>(1..<p)
        
        for x in Number(1)..<p {
            let xx = x.power(2, modulus: p)
            allSquares.insert([x, xx])
        }
        
        for roots in allSquares {
            let (x, xx) = (roots.first!, roots.last!)
            guard let calculatedRoots = squareRoots(of: xx, modulus: p) else {
                XCTFail("Got no roots")
                return
            }
            XCTAssertTrue(calculatedRoots.contains(x))
            notSquares.remove(xx)
        }
        
        for x in notSquares {
            XCTAssertNil(squareRoots(of: x, modulus: p))
        }
    }
    
    func testExtendedEuclidean() {
        func _test(_ a: Number, _ b: Number, expected: (gcd: Number, bézoutCoefficients: (Number, Number))) {
            let result = extendedGreatestCommonDivisor(a, b)
            XCTAssertEqual(result.gcd, expected.gcd)
            
            XCTAssertEqual(result.bézoutCoefficients.0, expected.bézoutCoefficients.0)
            XCTAssertEqual(result.bézoutCoefficients.1, expected.bézoutCoefficients.1)
            
        }
        
        _test(15, 145, expected: (gcd: 5, bézoutCoefficients: (10, -1)))
        _test(1914, 899, expected: (gcd: 29, bézoutCoefficients: (8, -17)))
        _test(1432, 123211, expected: (gcd: 1, bézoutCoefficients: (-22973, 267)))
    }
    
    func testSquareRoots3Mod4() {
        let p = Number(7919)
        assert(mod(p, modulus: 4) == 3)
        _testAllSquareRoots(p)
    }
    
    func testSquareRoots5Mod8() {
        let p = Number(7901)
        assert(mod(p, modulus: 8) == 5)
        _testAllSquareRoots(p)
    }
    
    func testOtherSquareRoots() {
        let p = Number(7873)
        assert(mod(p, modulus: 4) == 1)
        assert(mod(p, modulus: 8) == 1)
        _testAllSquareRoots(p)
    }
    
    
    func testModularInverse() {
        func _test(modInvOf x: Number, mod p: Number, expect expected: Number) {
            XCTAssertEqual(
                divide(1, by: x, mod: p),
                expected
            )
    
        }
        
        _test(modInvOf: 17, mod: 3120, expect: 2753)
        // https://math.stackexchange.com/a/1163313
        _test(modInvOf: 8, mod: 77, expect: 29)
        _test(modInvOf: 8, mod: 7, expect: 1)
        _test(modInvOf: 8, mod: 11, expect: 7)
        
        // using http://reference.wolfram.com/language/ref/PowerMod.html
        func _testMod2(invOf y: Number, expected: Number) {
            _test(modInvOf: y, mod: 2, expect: expected)
        }
        
        func _testMod3(invOf y: Number, expected: Number) {
            _test(modInvOf: y, mod: 3, expect: expected)
        }
        
        func _testMod4(invOf y: Number, expected: Number) {
            _test(modInvOf: y, mod: 4, expect: expected)
        }
        
        func _testMod5(invOf y: Number, expected: Number) {
            _test(modInvOf: y, mod: 5, expect: expected)
        }
        
        func _testMod7(invOf y: Number, expected: Number) {
            _test(modInvOf: y, mod: 7, expect: expected)
        }
        
        func _testMod11(invOf y: Number, expected: Number) {
            _test(modInvOf: y, mod: 11, expect: expected)
        }
        
        func _testMod13(invOf y: Number, expected: Number) {
            _test(modInvOf: y, mod: 13, expect: expected)
        }
        
        _testMod2(invOf: 1, expected: 1)
        
        _testMod3(invOf: 1, expected: 1)
        _testMod3(invOf: 2, expected: 2)
        
        _testMod4(invOf: 1, expected: 1)
        _testMod4(invOf: 3, expected: 3)
        
        _testMod5(invOf: 1, expected: 1)
        _testMod5(invOf: 2, expected: 3)
        _testMod5(invOf: 3, expected: 2)
        _testMod5(invOf: 4, expected: 4)
        
        _testMod7(invOf: 1, expected: 1)
        _testMod7(invOf: 2, expected: 4)
        _testMod7(invOf: 3, expected: 5)
        _testMod7(invOf: 4, expected: 2)
        _testMod7(invOf: 5, expected: 3)
        _testMod7(invOf: 6, expected: 6)
        _testMod7(invOf: 10, expected: 5)
        _testMod7(invOf: 17, expected: 5)
        
        _testMod11(invOf: 2, expected: 6)
        _testMod11(invOf: 3, expected: 4)
        _testMod11(invOf: 4, expected: 3)
        _testMod11(invOf: 5, expected: 9)
        _testMod11(invOf: 6, expected: 2)
        _testMod11(invOf: 7, expected: 8)
        _testMod11(invOf: 8, expected: 7)
        _testMod11(invOf: 9, expected: 5)
        _testMod11(invOf: 10, expected: 10)
        
        _testMod13(invOf: 2, expected: 7)
        _testMod13(invOf: 3, expected: 9)
        _testMod13(invOf: 4, expected: 10)
        _testMod13(invOf: 5, expected: 8)
        _testMod13(invOf: 6, expected: 11)
        _testMod13(invOf: 7, expected: 2)
        _testMod13(invOf: 8, expected: 5)
        _testMod13(invOf: 9, expected: 3)
        _testMod13(invOf: 10, expected: 4)
        
    }
}
