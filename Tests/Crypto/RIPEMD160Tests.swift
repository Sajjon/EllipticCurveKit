//
//  RIPEMD160Tests.swift
//  EllipticCurveKit
//
//  Created by Alexander Cyon on 2019-04-07.
//  Copyright © 2019 Alexander Cyon. All rights reserved.
//

import Foundation
@testable import EllipticCurveKit
import XCTest
import CryptoSwift

extension RIPEMD160 {
    static func hexStringDigest(_ input: String) -> String {
        let data: Data = hexStringDigest(input)
        return data.toHexString()
    }
    
    static func asciiDigest(_ input: String) -> String {
        let data: Data = asciiDigest(input)
        return data.toHexString()
    }
}

class RIPEMD160Tests: XCTestCase {
    
    // Test vectors from http://homes.esat.kuleuven.be/~bosselae/RIPEMD160.html
    func testEmptyString() {
        let message = ""
        let hash = "9c1185a5c5e9fc54612808977ee8f548b2258d31"
        XCTAssertEqual(RIPEMD160.asciiDigest(message), hash)
    }
    
    func testMilionTimesA() {
        measure {
            let message = String(repeating: "a", count: 1_000_000)
            let hash = "52783243c1697bdbe16d37f97f68f08325dc1528"
            
            XCTAssertEqual(RIPEMD160.asciiDigest(message), hash)
        }
    }

    func testCyclicLeftShift() {
        let a:    UInt32 = 0b00111000001001101011100000010110
        let σ₁a:  UInt32 = 0b01110000010011010111000000101100
        let σ₁₀a: UInt32 = 0b10011010111000000101100011100000
        
        XCTAssertEqual(a ~<<  1, σ₁a)
        XCTAssertEqual(a ~<< 10, σ₁₀a)
    }
    
    func testAddedConstants() {
        let k40:UInt32 = 0x6ED9EBA1
        XCTAssertEqual(RIPEMD160.Block.K.left[40], k40)
    }
    
    func testBitlevelFunctions() {
        let x: UInt32 =       0b0000_0000_0000_1111
        let y: UInt32 =       0b1111_1111_1111_0000
        let z: UInt32 =       0b0000_1111_1111_0000
        
        let xORxOR: UInt32 =  0b1111_0000_0000_1111
        
        let function = RIPEMD160.Block().f(12)
        let result = function(x, y, z)
        
        XCTAssertEqual(result, xORxOR)
    }
    
    func testWordSelection() {
        let message: [UInt32] = [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0]
        let r63r = message[RIPEMD160.Block.R.right[63]]
        XCTAssertEqual(r63r, 2)
    }
    
    func testRotationAmount() {
        let s17r = RIPEMD160.Block.S.right[17]
        let expected: Int = 13
        
        XCTAssertEqual(s17r, expected)
    }
    
    func testZero() {
        // One of the test vectors  is an empty string. Should result in the same hash as 1 iteration.
        
        /* Padding rules according to: https://github.com/agoebel/RIPEMD160-160
         Start with 0x80 followed by zeros, followed by the 64-bit length of the string in BITS (bits = 8 times number of bytes) in little-endian form. */
        
        let message: [UInt32] = [UInt32(bigEndian: 0x80_00_00_00), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        // 0x80 is in little endian
        
        var digester = RIPEMD160.Block()
        digester.compress(message)
        
        let h0: UInt32 = digester.hash[0]
        let h1: UInt32 = digester.hash[1]
        let h2: UInt32 = digester.hash[2]
        let h3: UInt32 = digester.hash[3]
        let h4: UInt32 = digester.hash[4]
        
        // "" -> 9c1185a5 c5e9fc54 61280897 7ee8f548 b2258d31
        
        XCTAssertEqual(h0, UInt32(bigEndian: 0x9c1185a5)) // 0x9c1185a5 is in little endian
        XCTAssertEqual(h1, UInt32(bigEndian: 0xc5e9fc54))
        XCTAssertEqual(h2, UInt32(bigEndian: 0x61280897))
        XCTAssertEqual(h3, UInt32(bigEndian: 0x7ee8f548))
        XCTAssertEqual(h4, UInt32(bigEndian: 0xb2258d31))
    }
    
    func testA() {
        // "a" is another test vector. This allows to test thorny issues like padding rules,
        // conversion from ASCII to bytes and endianess.
        let a: UInt32 = UInt32(bigEndian: 0x61_80_00_00)
        // Message gets padded with 0x80 and zeros. The last 8 bytes
        // store, in little endian, the length of the message in bits.
        let message: [UInt32] = [a, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0]
        var digester = RIPEMD160.Block()
        digester.compress(message)
        
        let h0: UInt32 = digester.hash[0]
        let h1: UInt32 = digester.hash[1]
        let h2: UInt32 = digester.hash[2]
        let h3: UInt32 = digester.hash[3]
        let h4: UInt32 = digester.hash[4]
        
        XCTAssertEqual(h0, UInt32(bigEndian: 0x0bdc9d2d))
        XCTAssertEqual(h1, UInt32(bigEndian: 0x256b3ee9))
        XCTAssertEqual(h2, UInt32(bigEndian: 0xdaae347b))
        XCTAssertEqual(h3, UInt32(bigEndian: 0xe6f4dc83))
        XCTAssertEqual(h4, UInt32(bigEndian: 0x5a467ffe))
        
    }
    
    func testRosettaCode() {
        var block = RIPEMD160.Block()
        let message:[UInt32] = [0x65_73_6f_52, 0x20_61_74_74, 0x65_64_6f_43, 0x00_00_00_80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 96, 0]
        block.compress(message)
        
        let digest = NSString(format: "%2x%2x%2x%2x%2x", UInt32(bigEndian: block.hash[0]), UInt32(bigEndian: block.hash[1]), UInt32(bigEndian: block.hash[2]), UInt32(bigEndian: block.hash[3]), UInt32(bigEndian: block.hash[4]))
        
        XCTAssertEqual(digest, "b3be159860842cebaa7174c8fff0aa9e50a5199f")
    }
    
    func testAsciiA() {
        let message = "a"
        let hash = "0bdc9d2d256b3ee9daae347be6f4dc835a467ffe"
        
        XCTAssertEqual(RIPEMD160.asciiDigest(message), hash)
    }
    
    func testABC() {
        let message = "abc"
        let hash = "8eb208f7e05d987a9b044a8e98c6b087f15a0bfc"
        
        XCTAssertEqual(RIPEMD160.asciiDigest(message), hash)
    }
    
    func testMessageDigest() {
        let message = "message digest"
        let hash = "5d0689ef49d2fae572b881b123a85ffa21595f36"
        
        XCTAssertEqual(RIPEMD160.asciiDigest(message), hash)
    }
    
    func testAlphabet() {
        let message = "abcdefghijklmnopqrstuvwxyz"
        let hash = "f71c27109c692c1b56bbdceb5b9d2865b3708dbc"
        
        XCTAssertEqual(RIPEMD160.asciiDigest(message), hash)
    }
    
    func testAlphabetSoup() {
        let message = "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
        let hash = "12a053384a9c0c88e405a06c27dcf49ada62eb2b"
        
        XCTAssertEqual(RIPEMD160.asciiDigest(message), hash)
    }
    
    func testAplhabetUpcaseDowncaseNumbers() {
        let message = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        let hash = "b0e20b6e3116640286ed3a87a5713079b21f5189"
        
        XCTAssertEqual(RIPEMD160.asciiDigest(message), hash)
    }
    
    func testManyNumbers() {
        let numbers = "1234567890"
        var message = ""
        for _ in 1...8 {
            message += numbers
        }
        
        let hash = "9b752e45573d4b39f4dbd3323cab82bf63326bfb"
        
        XCTAssertEqual(RIPEMD160.asciiDigest(message), hash)
    }
    

    // Hex string example from https://en.bitcoin.it/wiki/Technical_background_of_version_1_Bitcoin_addresses
    func testHexString() {
        let message = "600ffe422b4e00731a59557a5cca46cc183944191006324a447bdb2d98d4b408" // 256 bit integer
        let hash = "010966776006953d5567439e5e39f86a0d273bee"
        
        XCTAssertEqual(RIPEMD160.hexStringDigest(message), hash)
        
    }
    
    // Some other vectors
    func testSingleBlockMessage() {
        // 55 characters = 1 block without zero padding (see test55charactersNotPadded)
        let message = "Sed ut perspiciatis unde omnis iste natus error sit vol"
        let hash    = "e6f95b697f98c944e6234a6313e11e179c8e867c"
        XCTAssertEqual(RIPEMD160.asciiDigest(message), hash)
    }
    
    
    func testQuadBlockMessage() {
        let message = "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia"
        
        let hash    = "5f5b48448f5e0abab49da46b9c8c0b0395eac519"
        XCTAssertEqual(RIPEMD160.asciiDigest(message), hash)
    }
    
    // RIPEMD160 blocks
    func testGetWordsInSection() {
        let message = "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa."
        let data: Data = message.toData(encodingForced: .ascii)
        let expected: Int = 128
        XCTAssertEqual(data.count, expected)
        let section  = RIPEMD160.getWordsInSection(data, 1)
        let psaDot:    UInt32 = UInt32(bigEndian: 0x70_73_61_2e) // "psa."
        let section15: UInt32 = section[15]
        XCTAssertEqual(section15, psaDot, "'psa.' not found in 2nd section: `\(RIPEMD160.encodeWords([section15]).toHexString())`")
    }
    
    func testEncodeWords() {
        // Message: "Sed ut perspiciatis unde omnis iste natus error sit vol"
        // Hash:    "e6f95b697f98c944e6234a6313e11e179c8e867c"
        let hashWords = [
            UInt32(bigEndian:0xe6f95b69),
            UInt32(bigEndian:0x7f98c944),
            UInt32(bigEndian:0xe6234a63),
            UInt32(bigEndian:0x13e11e17),
            UInt32(bigEndian:0x9c8e867c)
        ]
        XCTAssertEqual(RIPEMD160.encodeWords(hashWords).toHexString(), "e6f95b697f98c944e6234a6313e11e179c8e867c")
    }
    
    func test55charactersNotPadded() {
        /* Multiples of 64 characters minus 9 don't need padding. The 9th last byte is used to write 0x80. The last 8 bytes store the length. A string of 55 characters should only be appended with 0x80 and the two length bytes making it 64 bytes long. */
        let message = "Sed ut perspiciatis unde omnis iste natus error sit vol"
        let data = message.toData(encodingForced: .ascii)
        XCTAssertEqual(data.count, 55)
        var paddedData = data
        let stop: [UInt8] = [UInt8(0x80)] // 2^8
        paddedData += stop
        let lengthBytes: [UInt32] = [55 * 8, 0]
        paddedData += RIPEMD160.encodeWords(lengthBytes)
        XCTAssertEqual(paddedData.count, 64)
        let result = RIPEMD160.pad(data)
        XCTAssertEqual(result.count, 64)
        XCTAssertEqual(result[15], UInt8(0x61), "16th character is not 'a'")
        XCTAssertEqual(result[54], UInt8(0x6C), "55th character is not 'l'")
        XCTAssertEqual(result, paddedData, "`\(result.toHexString())` does not equal expected: `\(paddedData.toHexString())`")
    }
}
