import Foundation
@testable import SwiftCrypto

let secp256k1 = AnyEllipticCurveOverFiniteField.secp256k1
let privateKey = PrivateKey(hexString: "0x29ee955feda1a85f87ed4004958479706ba6c71fc99a67697a9a13d9d08c618e", on: secp256k1)!
let keyPair = KeyPair(privateKey: privateKey)
print(keyPair)

//
///*
// * Finite Field Integer
// */
//print("\n1. Finite Field Integer\n")
//
//let p: UInt8 = 223
//
//struct MyFFInt: FiniteFieldInteger {
//    static var Characteristic = p
//
//    var value: UInt8
//
//    init() {
//        value = 0
//    }
//}
//
//let a: MyFFInt = 1
//let b: MyFFInt = 200
//print(a + b)
//
///* Elliptic Curve
// *
// * before using any Type in the contruction of your ECPoint structs/classes
// * make sure you add the `extension <Type>: BasicArithmeticOperations {}`
// * just as below
// */
//print("\n2. Elliptic Curve\n")
//
//extension Double: BasicArithmeticOperations {}
//
//struct MyECPoint: EllipticCurve {
//    static var a: Double = -1
//    static var b: Double = 1
//
//    var x: Double
//    var y: Double?
//
//    init() {
//        x = 0
//    }
//}
//
//let point: MyECPoint = MyECPoint(x: 1, y: 1)
//print(point.description)
//
///* Elliptic Curve over Finite Field
// *
// * to declare an ECC, you'll need to have a ffint first
// * declare it either within your ECPoint struct or outside
// * and then use it as the typealias in ECPoint
// */
//print("\n3. Elliptic Curve over Finite Field\n")
//
//let P: UInt8 = 223
//
//struct FFInt223: FiniteFieldInteger {
//    static var Characteristic: UInt8 = P
//    var value: UInt8
//
//    init() {
//        value = 0
//    }
//}
//
//struct MyECFF: EllipticCurveOverFiniteField {
//
//    /*
//     * the order of this field is 212
//     * meaning 212 * G == Infinity
//     * a fun exercise is to enumerate all
//     * points of the curve, since there
//     * are only 211 non-infinity points
//     */
//    static var Order: UInt8 = 212
//
//    static var a: FFInt223 = 2
//    static var b: FFInt223 = 7
//
//    var x: FFInt223
//    var y: FFInt223?
//
//    static var Generator: MyECFF = MyECFF(x: 16, y: 11)
//
//    init() {
//        x = 0
//    }
//}
//
//print(MyECFF())
//print(200 * MyECFF.One)
//print(212 * MyECFF.One)
//
///*
// * Secp256k1
// */
//print("\n4. Secp256k1\n")
//
//let randomNumber: UInt256 = 3
//let address: Secp256k1 = randomNumber * Secp256k1.Generator
//print(address)
