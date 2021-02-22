//
//  DER.swift
//  
//
//  Created by Johan Nordberg on 2021/02/22.
//
import Foundation
import XCTest
@testable import EllipticCurveKit

let r: Number = "52617691991220931227794138107685429667129144574515111025493805026351628195312"
let s: Number = "69650880131778720500573473496750533897225181277314667394632202424067811752564"
let data = Data(hex: "3045022074548eebb0294166e9aae01abe57196d7723feb334ddd1e92953107abbd495f002210099fd0049db199ade30fa239e17c9840709ea112f4d374bb4693b039c2c08ba74")

class DERTest: XCTestCase {
    func testDecode() {
        let decoded = derDecode(data: data)
        XCTAssertEqual(decoded?.r, r)
        XCTAssertEqual(decoded?.s, s)
    }

    func testEncode() {
        let encoded = derEncode(r: r, s: s)
        XCTAssertEqual(encoded, data.asHex)
        
    }
}
