//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2021-03-02.
//

import Foundation
import XCTest

extension XCTestCase {
    
    func forwardFailure(
        description: String,
        inFile filePath: String = #file,
        atLine line: UInt = #line,
        expected: Bool = false
    ) {

        record(
            XCTIssue(
                type: .assertionFailure,
                compactDescription: description,
                detailedDescription: expected ? "Expected a failure." : "Did not expect this failure.",
                sourceCodeContext: XCTSourceCodeContext(
                    location: XCTSourceCodeLocation(
                        filePath: filePath,
                        lineNumber: Int(line)
                    )
                ),
                associatedError: nil,
                attachments: []
            )
        )
    }
    
    
    /// Since `Foobar.Type` does not conform to `Equatable`, even if `Foobar` conforms to `Equatable`, we are unable to write `XCTAssertEquals(type(of: foo), Foobar.self)`, this assert method fixes that.
    @discardableResult
    func XCTAssertType<Actual, Expected>(
        of actual: Actual,
        is expectedType: Expected.Type,
        
        _ filePath: String = #file,
        line: UInt = #line
    ) -> Expected! {
        
        if let expected = actual as? Expected { return expected /* success */  }
        let actualType = Mirror(reflecting: actual).subjectType
        
        
        forwardFailure(
            description: "Expected '\(actual)' to be of type '\(expectedType)', but was: '\(actualType)'",
            
            inFile: filePath,
            atLine: line,
            expected: false
        )
        return nil
    }
    
    @discardableResult
    func XCTAssertType<Actual, Expected>(
        of actual: Actual,
        _ filePath: String = #file,
        line: UInt = #line
    ) -> Expected! {
        return XCTAssertType(of: actual, is: Expected.self, filePath, line: line)
    }
    
    func XCTAssertNotThrowsAndEqual<Result>(
        file: StaticString = #file,
        line: UInt = #line,
        _ codeThatShouldNotThrow: @autoclosure () throws -> Result,
        _ expectedValue: Result,
        _ message: String = ""
    ) where Result: Equatable {
        guard
            let result = XCTAssertNotThrows(
                file: file,
                line: line,
                try codeThatShouldNotThrow()
            )
        else {
            return XCTFail("Unable to assert equality since expression threw error", file: file, line: line)
        }
        XCTAssertEqual(result, expectedValue, message, file: file, line: line)
    }
    
    
    @discardableResult
    func XCTAssertNotThrows<Result>(
        file: StaticString = #file,
        line: UInt = #line,
        _ codeThatShouldNotThrow: @autoclosure () throws -> Result
    ) -> Result? {
        
        do {
            return try codeThatShouldNotThrow()
        } catch {
            XCTFail("Unexpected error: \(error)", file: file, line: line)
            return nil
        }
    }
    
    func XCTAssertNotThrows<Result>(
        file: StaticString = #file,
        line: UInt = #line,
        _ codeThatShouldNotThrow: @autoclosure () throws -> Result,
        innerAssert: (Result) -> Void
    ) {
        guard let result = XCTAssertNotThrows(file: file, line: line, try codeThatShouldNotThrow()) else { return }
        innerAssert(result)
    }
    
    
    func XCTAssertThrowsSpecificError<ReturnValue, ExpectedError>(
        file: StaticString = #file,
        line: UInt = #line,
        _ codeThatThrows: @autoclosure () throws -> ReturnValue,
        _ error: ExpectedError,
        _ message: String = ""
    ) where ExpectedError: Swift.Error & Equatable {
        
        XCTAssertThrowsError(try codeThatThrows(), message, file: file, line: line) { someError in
            guard let expectedErrorType = someError as? ExpectedError else {
                XCTFail("Expected code to throw error of type: <\(ExpectedError.self)>, but got error: <\(someError)>, of type: <\(type(of: someError))>")
                return
            }
            XCTAssertEqual(expectedErrorType, error, line: line)
        }
    }
    
    func XCTAssertThrowsSpecificError<ExpectedError>(
        _ codeThatThrows: @autoclosure () throws -> Void,
        _ error: ExpectedError,
        _ message: String = ""
    ) where ExpectedError: Swift.Error & Equatable {
        XCTAssertThrowsError(try codeThatThrows(), message) { someError in
            guard let expectedErrorType = someError as? ExpectedError else {
                XCTFail("Expected code to throw error of type: <\(ExpectedError.self)>, but got error: <\(someError)>, of type: <\(type(of: someError))>")
                return
            }
            XCTAssertEqual(expectedErrorType, error)
        }
    }
    
    func XCTAssertThrowsSpecificErrorType<Error>(
        _ codeThatThrows: @autoclosure () throws -> Void,
        _ errorType: Error.Type,
        _ message: String = ""
    ) where Error: Swift.Error & Equatable {
        XCTAssertThrowsError(try codeThatThrows(), message) { someError in
            XCTAssertTrue(someError is Error, "Expected code to throw error of type: <\(Error.self)>, but got error: <\(someError)>, of type: <\(type(of: someError))>")
        }
    }
    
    func XCTAssertContains(_ haystack: String?, _ needle: String?) {
        guard let needle = needle else { return XCTFail("Needle is nil") }
        guard let haystack = haystack else { return XCTFail("Haystack is nil") }
        XCTAssertTrue(haystack.contains(needle))
    }
    
    func XCTAssertNotContains(_ haystack: String?, _ needle: String?) {
        guard let haystack = haystack else { return XCTFail("Haystack is nil") }
        guard let needle = needle else {
            return // Definition... we expected haystack to NOT contain needle, if needle is nil, did we actually pass the test?
        }
        XCTAssertFalse(haystack.contains(needle))
    }
    
    
    func XCTAssertAllEqual<Item>(_ items: Item...) where Item: Equatable {
        forAll(items) {
            XCTAssertEqual($0, $1)
        }
    }
    
    func XCTAssertAllInequal<Item>(_ items: Item...) where Item: Equatable {
        forAll(items) {
            XCTAssertNotEqual($0, $1)
        }
    }
    
    private func forAll<Item>(_ items: [Item], compareElemenets: (Item, Item) -> Void) where Item: Equatable {
        var lastIndex: Array<Item>.Index?
        for index in items.indices {
            defer { lastIndex = index }
            guard let last = lastIndex else { continue }
            let fooElement: Item = items[last]
            let barElement: Item = items[index]
            compareElemenets(fooElement, barElement)
        }
    }
    
}
