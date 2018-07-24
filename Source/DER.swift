//
//  DER.swift
//  SwiftCrypto
//
//  Created by Alexander Cyon on 2018-07-22.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

//import SwiftyRSA




//
//extension Data {
//    var firstByte: UInt8 {
//        var byte: UInt8 = 0
//        copyBytes(to: &byte, count: MemoryLayout<UInt8>.size)
//        return byte
//    }
//}
//
///// Stolen from: https://gist.github.com/Jugale/2daaec0715d4f6d7347534d42bfa7110
//class SimpleScanner {
//    let data: Data
//
//    ///The current position of the scanning head
//    private(set) var position = 0
//
//    init(data: Data) {
//        self.data = data
//    }
//
//    /**
//     `true` if there are no more bytes available to scan.
//     */
//    var isComplete: Bool {
//        return position >= data.count
//    }
//
//    /**
//     Roll the scan head back to the position it was at before the last command was run.
//     If the last command failed, calling this does nothing as the scan head was already returned to it's state before failure
//     */
//    func rollback(distance: Int) {
//        position = position - distance
//
//        if position < 0 {
//            position = 0
//        }
//    }
//
//    /**
//     Scans `d` bytes, or returns `nil` and restores position if `d` is greater than the number of bytes remaining
//     */
//    func scan(distance: Int) -> Data? {
//        return popByte(s: distance)
//    }
//
//    /**
//     Scans to the end of the data.
//     */
//    func scanToEnd() -> Data? {
//        return scan(distance: data.count - position)
//    }
//
//    private func popByte(s: Int = 1) -> Data? {
//
//        guard s > 0 else { return nil }
//        guard position <= (data.count - s) else { return nil }
//
//        defer {
//            position = position + s
//        }
//
//        return data.subdata(in: data.startIndex.advanced(by: position)..<data.startIndex.advanced(by: position + s))
//    }
//}
//
//struct ASN1Object {
//    let type: DERCode
//    let data: Data
//}
//
//enum DERCode: UInt8 {
//
//    //All sequences should begin with this
//    //https://en.wikipedia.org/wiki/Abstract_Syntax_Notation_One#Example_encoded_in_DER
//    case sequence = 0x30
//
//    //Type tags - add more here!
//    //http://www.obj-sys.com/asn1tutorial/node10.html
//    case boolean = 0x01
//    case integer = 0x02
//    case ia5String = 0x16
//
//    static func allTypes() -> [DERCode] {
//        return [
//            .boolean,
//            .integer,
//            .ia5String
//        ]
//    }
//}
//
//struct ASN1DERDecoder {
//    static func decode(data: Data) -> [ASN1Object]? {
//        let scanner = SimpleScanner(data: data)
//        //Verify that this is actually a DER sequence
//        guard scanner.scan(distance: 1)?.firstByte == DERCode.sequence.rawValue else {
//            return nil
//        }
//        //The second byte should equate to the length of the data, minus itself and the sequence type
//        guard let expectedLength = scanner.scan(distance: 1)?.firstByte, Int(expectedLength) == data.count - 2 else {
//            return nil
//        }
//        var output: [ASN1Object] = []
//        while !scanner.isComplete {
//            //Search the current position of the sequence for a known type
//            var dataType: DERCode?
//            for type in DERCode.allTypes() {
//                if scanner.scan(distance: 1)?.firstByte == type.rawValue {
//                    dataType = type
//                } else {
//                    scanner.rollback(distance: 1)
//                }
//            }
//            guard let type = dataType else {
//                fatalError("Unsupported type - add it to `enum DERCode`")
//            }
//
//            guard let length = scanner.scan(distance: 1) else {
//                //Expected a byte describing the length of the proceeding data
//                return nil
//            }
//
//            let lengthInt = length.firstByte
//
//            guard let actualData = scanner.scan(distance: Int(lengthInt)) else {
//                //Expected to be able to scan `lengthInt` bytes
//                return nil
//            }
//
//            let object = ASN1Object(type: type, data: actualData)
//            output.append(object)
//        }
//        return output
//    }
//}
//
//
//struct ASN1DEREncoder {
//    static func encode(ans1Objects: [ASN1Object]) -> Data? {
//
//
//
//        return [ASN1Object](arrayLiteral:
//            ASN1Object(type: .sequence, data: <#T##Data#>)
//        ]
//
//        let scanner = SimpleScanner(data: data)
//        //Verify that this is actually a DER sequence
//        guard scanner.scan(distance: 1)?.firstByte == DERCode.sequence.rawValue else {
//            return nil
//        }
//        //The second byte should equate to the length of the data, minus itself and the sequence type
//        guard let expectedLength = scanner.scan(distance: 1)?.firstByte, Int(expectedLength) == data.count - 2 else {
//            return nil
//        }
//        var output: [ASN1Object] = []
//        while !scanner.isComplete {
//            //Search the current position of the sequence for a known type
//            var dataType: DERCode?
//            for type in DERCode.allTypes() {
//                if scanner.scan(distance: 1)?.firstByte == type.rawValue {
//                    dataType = type
//                } else {
//                    scanner.rollback(distance: 1)
//                }
//            }
//            guard let type = dataType else {
//                fatalError("Unsupported type - add it to `enum DERCode`")
//            }
//
//            guard let length = scanner.scan(distance: 1) else {
//                //Expected a byte describing the length of the proceeding data
//                return nil
//            }
//
//            let lengthInt = length.firstByte
//
//            guard let actualData = scanner.scan(distance: Int(lengthInt)) else {
//                //Expected to be able to scan `lengthInt` bytes
//                return nil
//            }
//
//            let object = ASN1Object(type: type, data: actualData)
//            output.append(object)
//        }
//        return output
//    }
//}
