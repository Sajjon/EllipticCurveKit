////
////  KeyDataToHexStringTrimmingTests.swift
////  SwiftCryptoTests
////
////  Created by Alexander Cyon on 2018-06-08.
////  Copyright © 2018 Alexander Cyon. All rights reserved.
////

import Foundation
import XCTest
@testable import SwiftCrypto

class KeyDataToHexStringTrimmingTests: KeyDataTests {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func assert(trim: Bool, separator: String, _ keyData: KeyDataStruct, expected: String, line: Int) {
        let hex = keyData.asHexString(separator: separator, trimLeadingZeros: trim)
        let message = "Expected: `\(expected)`, but hexString was: '\(hex)', using separator: '\(separator)', and trimLeadingZeros: `\(trim)`, line: \(line)"
        XCTAssertEqual(expected, hex, message)
    }

    // MARK: -
    // MARK: - TRIM -
    // MARK: -

    // MARK: - SEPARATOR EMPTY -

    // MARK: - Single Element
    func caseSingleTrimmedEmptySeparator(_ keyData: KeyDataStruct, expected: String, line: Int = #line) {
        XCTAssertEqual(1, keyData.length, "Length should be 1")
        assert(trim: true, separator: "", keyData, expected: expected, line: line)
    }

    func testTrimmedEmptySeparatorSingleElement() {
        caseSingleTrimmedEmptySeparator([0], expected: "0")
        caseSingleTrimmedEmptySeparator([00], expected: "0")
        caseSingleTrimmedEmptySeparator([000], expected: "0")
        caseSingleTrimmedEmptySeparator([0000], expected: "0")
        caseSingleTrimmedEmptySeparator([1], expected: "1")
        caseSingleTrimmedEmptySeparator([01], expected: "1")
        caseSingleTrimmedEmptySeparator([001], expected: "1")
        caseSingleTrimmedEmptySeparator([0001], expected: "1")
        caseSingleTrimmedEmptySeparator([10], expected: "A")
        caseSingleTrimmedEmptySeparator([010], expected: "A")
        caseSingleTrimmedEmptySeparator([0010], expected: "A")
        caseSingleTrimmedEmptySeparator([00010], expected: "A")
        caseSingleTrimmedEmptySeparator([11259375], expected: "ABCDEF")
        caseSingleTrimmedEmptySeparator([011259375], expected: "ABCDEF")
        caseSingleTrimmedEmptySeparator([0011259375], expected: "ABCDEF")
        caseSingleTrimmedEmptySeparator([11256099], expected: "ABC123")
        caseSingleTrimmedEmptySeparator([01], expected: "1")
        caseSingleTrimmedEmptySeparator([0001], expected: "1")
        caseSingleTrimmedEmptySeparator([01010], expected: "3F2")
        caseSingleTrimmedEmptySeparator([001010], expected: "3F2")
        XCTAssertEqual(
            KeyDataStruct([1010]).asHexString(trimLeadingZeros: true),
            KeyDataStruct([001010]).asHexString(trimLeadingZeros: true)
        )
    }

    // MARK: - Multiple Element -
    func caseMultiElementTrimmedEmptySeparator(_ keyData: KeyDataStruct, expected: String, line: Int = #line) {
        XCTAssertTrue(keyData.length > 1, "Length should be over 1")
        assert(trim: true, separator: "", keyData, expected: expected, line: line)
    }

    func testTrimmedEmptySeparatorMultipleElement() {

        caseMultiElementTrimmedEmptySeparator([0, 0], expected: zeros(repeated: 2))
        caseMultiElementTrimmedEmptySeparator([00, 00], expected: zeros(repeated: 2))
        caseMultiElementTrimmedEmptySeparator([000, 000], expected: zeros(repeated: 2))
        caseMultiElementTrimmedEmptySeparator([0000, 0000], expected: zeros(repeated: 2))
        caseMultiElementTrimmedEmptySeparator([0, 1], expected: zeros() + zeros(then: "1"))
        caseMultiElementTrimmedEmptySeparator([1, 0], expected: zeros(then: "1") + zeros())
        caseMultiElementTrimmedEmptySeparator([0, 10], expected: zeros() + zeros(then: "A"))
        caseMultiElementTrimmedEmptySeparator([10, 0], expected: zeros(then: "A") + zeros())

        caseMultiElementTrimmedEmptySeparator([0, 11259375], expected: zeros() + zeros(then: "ABCDEF"))
        caseMultiElementTrimmedEmptySeparator([00, 11259375], expected: zeros() + zeros(then: "ABCDEF"))
        caseMultiElementTrimmedEmptySeparator([0, 011259375], expected: zeros() + zeros(then: "ABCDEF"))
        caseMultiElementTrimmedEmptySeparator([00, 011259375], expected: zeros() + zeros(then: "ABCDEF"))
        caseMultiElementTrimmedEmptySeparator([0000, 00011259375], expected: zeros() + zeros(then: "ABCDEF"))

        caseMultiElementTrimmedEmptySeparator([11259375, 0], expected: zeros(then: "ABCDEF") + zeros())
        caseMultiElementTrimmedEmptySeparator([11259375, 00], expected: zeros(then: "ABCDEF") + zeros())
        caseMultiElementTrimmedEmptySeparator([011259375, 0], expected: zeros(then: "ABCDEF") + zeros())
        caseMultiElementTrimmedEmptySeparator([011259375, 00], expected: zeros(then: "ABCDEF") + zeros())
        caseMultiElementTrimmedEmptySeparator([00011259375, 0000], expected: zeros(then: "ABCDEF") + zeros())

        caseMultiElementTrimmedEmptySeparator([001194684, 0], expected: zeros(then: "123ABC") + zeros())
        caseMultiElementTrimmedEmptySeparator([000001194684, 0], expected: zeros(then: "123ABC") + zeros())
        caseMultiElementTrimmedEmptySeparator([000001194684, 000000], expected: zeros(then: "123ABC") + zeros())
        XCTAssertEqual(
            KeyDataStruct([001194684, 0]).asHexString(trimLeadingZeros: true),
            KeyDataStruct([000001194684, 0]).asHexString(trimLeadingZeros: true)
        )
    }



    // MARK: -
    // MARK: - SEPARATOR COMMA -
    // MARK: -


    // MARK: - Single Element
    func caseSingleTrimmedCommaSeparator(_ keyData: KeyDataStruct, expected: String, line: Int = #line) {
        XCTAssertEqual(1, keyData.length, "Length should be 1")
        assert(trim: true, separator: ", ", keyData, expected: expected, line: line)
    }

    func testTrimmedCommaSeparatorSingleElement() {
        caseSingleTrimmedCommaSeparator([0], expected: "0")
        caseSingleTrimmedCommaSeparator([00], expected: "0")
        caseSingleTrimmedCommaSeparator([000], expected: "0")
        caseSingleTrimmedCommaSeparator([0000], expected: "0")
        caseSingleTrimmedCommaSeparator([1], expected: "1")
        caseSingleTrimmedCommaSeparator([01], expected: "1")
        caseSingleTrimmedCommaSeparator([001], expected: "1")
        caseSingleTrimmedCommaSeparator([0001], expected: "1")
        caseSingleTrimmedCommaSeparator([10], expected: "A")
        caseSingleTrimmedCommaSeparator([010], expected: "A")
        caseSingleTrimmedCommaSeparator([0010], expected: "A")
        caseSingleTrimmedCommaSeparator([00010], expected: "A")
        caseSingleTrimmedCommaSeparator([11259375], expected: "ABCDEF")
        caseSingleTrimmedCommaSeparator([011259375], expected: "ABCDEF")
        caseSingleTrimmedCommaSeparator([0011259375], expected: "ABCDEF")
        caseSingleTrimmedCommaSeparator([11256099], expected: "ABC123")
        caseSingleTrimmedCommaSeparator([01], expected: "1")
        caseSingleTrimmedCommaSeparator([0001], expected: "1")
        caseSingleTrimmedCommaSeparator([01010], expected: "3F2")
        caseSingleTrimmedCommaSeparator([001010], expected: "3F2")
        XCTAssertEqual(
            KeyDataStruct([1010]).asHexString(trimLeadingZeros: true),
            KeyDataStruct([001010]).asHexString(trimLeadingZeros: true)
        )
    }

    // MARK: - Multiple Element -
    func caseMultiElementTrimmedCommaSeparator(_ keyData: KeyDataStruct, expected: String, line: Int = #line) {
        XCTAssertTrue(keyData.length > 1, "Length should be over 1")
        assert(trim: true, separator: ", ", keyData, expected: expected, line: line)
    }

    func testTrimmedCommaSeparatorMultipleElement() {
        caseMultiElementTrimmedCommaSeparator([0, 0], expected: "0, 0")
        caseMultiElementTrimmedCommaSeparator([00, 00], expected: "0, 0")
        XCTAssertEqual(
            KeyDataStruct([0, 0]).asHexString(separator: ", ", trimLeadingZeros: true),
            KeyDataStruct([00, 00]).asHexString(separator: ", ", trimLeadingZeros: true)
        )

        caseMultiElementTrimmedCommaSeparator([0, 000], expected: "0, 0")
        caseMultiElementTrimmedCommaSeparator([000, 00], expected: "0, 0")
        caseMultiElementTrimmedCommaSeparator([0, 1], expected: "1")
        caseMultiElementTrimmedCommaSeparator([0, 01], expected: "1")
        caseMultiElementTrimmedCommaSeparator([00, 01], expected: "1")
        caseMultiElementTrimmedCommaSeparator([10, 01], expected: "A, 1")
        caseMultiElementTrimmedCommaSeparator([10, 0], expected: "A, 0")
        caseMultiElementTrimmedCommaSeparator([010, 01], expected: "A, 1")
        caseMultiElementTrimmedCommaSeparator([010, 0], expected: "A, 0")

        caseMultiElementTrimmedCommaSeparator([0, 11259375], expected: "ABCDEF")
        caseMultiElementTrimmedCommaSeparator([00, 11259375], expected: "ABCDEF")
        caseMultiElementTrimmedCommaSeparator([00, 011259375], expected: "ABCDEF")
        caseMultiElementTrimmedCommaSeparator([0, 011259375], expected: "ABCDEF")
        caseMultiElementTrimmedCommaSeparator([000, 00011259375], expected: "ABCDEF")
        

        caseMultiElementTrimmedCommaSeparator([11259375, 0], expected: "ABCDEF, 0")
        caseMultiElementTrimmedCommaSeparator([11259375, 00], expected: "ABCDEF, 0")
        caseMultiElementTrimmedCommaSeparator([011259375, 0], expected: "ABCDEF, 0")
        caseMultiElementTrimmedCommaSeparator([011259375, 00], expected:  "ABCDEF, 0")
        caseMultiElementTrimmedCommaSeparator([00011259375, 0000], expected: "ABCDEF, 0")

        caseMultiElementTrimmedCommaSeparator([001194684, 0], expected: "123ABC, 0")
        caseMultiElementTrimmedCommaSeparator([000001194684, 0], expected: "123ABC, 0")
        caseMultiElementTrimmedCommaSeparator([000001194684, 000000], expected: "123ABC, 0")
    }

    // MARK: -
    // MARK: - DONT TRIM -
    // MARK: -

    // MARK: - SEPARATOR EMPTY -

    // MARK: - Single Element
    func caseSingleEmptySeparator(_ keyData: KeyDataStruct, expected: String, line: Int = #line) {
        XCTAssertEqual(1, keyData.length, "Length should be 1")
        assert(trim: false, separator: "", keyData, expected: expected, line: line)
    }

    func testEmptySeparatorSingleElement() {
        caseSingleEmptySeparator([0], expected: zeros())
        caseSingleEmptySeparator([00], expected: zeros())
        caseSingleEmptySeparator([000], expected: zeros())
        caseSingleEmptySeparator([0000], expected: zeros())
        caseSingleEmptySeparator([1], expected: zeros(then: "1"))
        caseSingleEmptySeparator([01], expected: zeros(then: "1"))
        caseSingleEmptySeparator([001], expected: zeros(then: "1"))
        caseSingleEmptySeparator([0001], expected: zeros(then: "1"))
        caseSingleEmptySeparator([0000000000000001], expected: zeros(then: "1"))
        caseSingleEmptySeparator([10], expected: zeros(then: "A"))
        caseSingleEmptySeparator([010], expected: zeros(then: "A"))
        caseSingleEmptySeparator([0010], expected: zeros(then: "A"))
        caseSingleEmptySeparator([00010], expected: zeros(then: "A"))
        caseSingleEmptySeparator([11259375], expected: zeros(then: "ABCDEF"))
        caseSingleEmptySeparator([011259375], expected: zeros(then: "ABCDEF"))
        caseSingleEmptySeparator([0011259375], expected: zeros(then: "ABCDEF"))
        caseSingleEmptySeparator([11256099], expected: zeros(then: "ABC123"))
        caseSingleEmptySeparator([0001], expected: zeros(then: "1"))
        caseSingleEmptySeparator([01010], expected: zeros(then: "3F2"))
        caseSingleEmptySeparator([001010], expected: zeros(then: "3F2"))
        XCTAssertEqual(
            KeyDataStruct([1010]).asHexString(trimLeadingZeros: false),
            KeyDataStruct([001010]).asHexString(trimLeadingZeros: false)
        )
    }


    // MARK: - Multiple Element -
    func caseMultiElementEmptySeparator(_ keyData: KeyDataStruct, expected: String, line: Int = #line) {
        XCTAssertTrue(keyData.length > 1, "Length should be over 1")
        assert(trim: false, separator: "", keyData, expected: expected, line: line)
    }

    func testEmptySeparatorMultipleElement() {

        caseMultiElementEmptySeparator([0, 0], expected: zeros(repeated: 2))
        caseMultiElementEmptySeparator([00, 00], expected: zeros(repeated: 2))
        caseMultiElementEmptySeparator([000, 000], expected: zeros(repeated: 2))
        caseMultiElementEmptySeparator([0000, 0000], expected: zeros(repeated: 2))
        caseMultiElementEmptySeparator([0, 1], expected: zeros() + zeros(then: "1"))
        caseMultiElementEmptySeparator([1, 0], expected: zeros(then: "1") + zeros())
        caseMultiElementEmptySeparator([0, 10], expected: zeros() + zeros(then: "A"))
        caseMultiElementEmptySeparator([10, 0], expected: zeros(then: "A") + zeros())

        caseMultiElementEmptySeparator([0, 11259375], expected: zeros() + zeros(then: "ABCDEF"))
        caseMultiElementEmptySeparator([00, 11259375], expected: zeros() + zeros(then: "ABCDEF"))
        caseMultiElementEmptySeparator([0, 011259375], expected: zeros() + zeros(then: "ABCDEF"))
        caseMultiElementEmptySeparator([00, 011259375], expected: zeros() + zeros(then: "ABCDEF"))
        caseMultiElementEmptySeparator([0000, 00011259375], expected: zeros() + zeros(then: "ABCDEF"))

        caseMultiElementEmptySeparator([11259375, 0], expected: zeros(then: "ABCDEF") + zeros())
        caseMultiElementEmptySeparator([11259375, 00], expected: zeros(then: "ABCDEF") + zeros())
        caseMultiElementEmptySeparator([011259375, 0], expected: zeros(then: "ABCDEF") + zeros())
        caseMultiElementEmptySeparator([011259375, 00], expected: zeros(then: "ABCDEF") + zeros())
        caseMultiElementEmptySeparator([00011259375, 0000], expected: zeros(then: "ABCDEF") + zeros())

        caseMultiElementEmptySeparator([001194684, 0], expected: zeros(then: "123ABC") + zeros())
        caseMultiElementEmptySeparator([000001194684, 0], expected: zeros(then: "123ABC") + zeros())
        caseMultiElementEmptySeparator([000001194684, 000000], expected: zeros(then: "123ABC") + zeros())
        XCTAssertEqual(
            KeyDataStruct([001194684, 0]).asHexString(trimLeadingZeros: true),
            KeyDataStruct([000001194684, 0]).asHexString(trimLeadingZeros: true)
        )
    }

    // MARK: -
    // MARK: - SEPARATOR COMMA -
    // MARK: -


    // MARK: - Single Element
    func caseSingleCommaSeparator(_ keyData: KeyDataStruct, expected: String, line: Int = #line) {
        XCTAssertEqual(1, keyData.length, "Length should be 1")
        assert(trim: false, separator: ", ", keyData, expected: expected, line: line)
    }

    func testCommaSeparatorSingleElement() {
        caseSingleCommaSeparator([0], expected: zeros())
        caseSingleCommaSeparator([00], expected: zeros())
        caseSingleCommaSeparator([000], expected: zeros())
        caseSingleCommaSeparator([0000], expected: zeros())
        caseSingleCommaSeparator([1], expected: zeros(then: "1"))
        caseSingleCommaSeparator([01], expected: zeros(then: "1"))
        caseSingleCommaSeparator([001], expected: zeros(then: "1"))
        caseSingleCommaSeparator([0001], expected: zeros(then: "1"))
        caseSingleCommaSeparator([10], expected: zeros(then: "A"))
        caseSingleCommaSeparator([010], expected: zeros(then: "A"))
        caseSingleCommaSeparator([0010], expected: zeros(then: "A"))
        caseSingleCommaSeparator([00010], expected: zeros(then: "A"))
        caseSingleCommaSeparator([11259375], expected: zeros(then: "ABCDEF"))
        caseSingleCommaSeparator([011259375], expected: zeros(then: "ABCDEF"))
        caseSingleCommaSeparator([0011259375], expected: zeros(then: "ABCDEF"))
        caseSingleCommaSeparator([11256099], expected: zeros(then: "ABC123"))
        caseSingleCommaSeparator([01], expected: zeros(then: "1"))
        caseSingleCommaSeparator([0001], expected: zeros(then: "1"))
        caseSingleCommaSeparator([01010], expected: zeros(then: "3F2"))
        caseSingleCommaSeparator([001010], expected: zeros(then: "3F2"))
        XCTAssertEqual(
            KeyDataStruct([1010]).asHexString(trimLeadingZeros: false),
            KeyDataStruct([001010]).asHexString(trimLeadingZeros: false)
        )
    }

    // MARK: - Multiple Element -
    func caseMultiElementCommaSeparator(_ keyData: KeyDataStruct, expected: String, line: Int = #line) {
        XCTAssertTrue(keyData.length > 1, "Length should be over 1")
        assert(trim: false, separator: ", ", keyData, expected: expected, line: line)
    }

    func testCommaSeparatorMultipleElement() {
        caseMultiElementCommaSeparator([0, 0], expected: zeros(repeated: 2, separator: ", "))
        caseMultiElementCommaSeparator([00, 00], expected: zeros(repeated: 2, separator: ", "))
        XCTAssertEqual(
            KeyDataStruct([0, 0]).asHexString(separator: ", ", trimLeadingZeros: false),
            KeyDataStruct([00, 00]).asHexString(separator: ", ", trimLeadingZeros: false)
        )

        caseMultiElementCommaSeparator([0, 000], expected: zeros(repeated: 2, separator: ", "))
        caseMultiElementCommaSeparator([000, 00], expected: zeros(repeated: 2, separator: ", "))
        caseMultiElementCommaSeparator([0, 1], expected: [zeros(), zeros(then: "1")].joined(separator: ", "))
        caseMultiElementCommaSeparator([0, 01], expected: [zeros(), zeros(then: "1")].joined(separator: ", "))
        caseMultiElementCommaSeparator([00, 01], expected: [zeros(), zeros(then: "1")].joined(separator: ", "))
        caseMultiElementCommaSeparator([10, 01], expected: [zeros(then: "A"), zeros(then: "1")].joined(separator: ", "))
        XCTAssertEqual(
            KeyDataStruct([010, 01]).asHexString(separator: ", ", trimLeadingZeros: false),
            KeyDataStruct([10, 01]).asHexString(separator: ", ", trimLeadingZeros: false)
        )
        caseMultiElementCommaSeparator([0, 11259375], expected: [zeros(), zeros(then: "ABCDEF")].joined(separator: ", "))
        caseMultiElementCommaSeparator([1194684, 0], expected: [zeros(then: "123ABC"), zeros()].joined(separator: ", "))

        XCTAssertEqual(
            KeyDataStruct([1194684, 0]).asHexString(separator: ", ", trimLeadingZeros: false),
            KeyDataStruct([01194684, 000]).asHexString(separator: ", ", trimLeadingZeros: false)
        )
    }

}

func zeros(repeated: Int = 1, separator: String = "") -> String {
    let string = KeyDataStruct.zeros(repeated: repeated, separator: separator)
    let separatorCharacterValued = separator.isEmpty ? 0 : 1
    XCTAssertEqual(string.count, (KeyDataStruct.elementHexCharacterCount + separatorCharacterValued) * repeated)
    return string
}

func zeros(then nonZero: String) -> String {
    let string = KeyDataStruct.zeros(minus: nonZero.count) + nonZero
    XCTAssertEqual(string.count, KeyDataStruct.elementHexCharacterCount)
    return string
}

func charThenZeros(_ char: String) -> String {
    let string = char + KeyDataStruct.zeros(minus: char.count)
    XCTAssertEqual(string.count, KeyDataStruct.elementHexCharacterCount)
    return string
}

extension Int {
    func times(perform: () -> ()) {
        for _ in 0..<self {
            perform()
        }
    }
}

extension KeyData {
    static func zeros(minus: Int = 0, repeated: Int = 1, separator: String = "") -> String {
        let count = Self.elementHexCharacterCount - minus
        var array = [String]()
        repeated.times {
            array.append(String(repeating: "0", count: count))
        }
        return array.joined(separator: separator)
    }
}
