//  TestHelpers.swift
//  CountryFactsTests
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import Foundation
import XCTest
@testable import CountryFacts

/// Test helpers and utilities for unit tests.
enum TestHelpers {
    /// Creates a test country with default values.
    static func makeTestCountry(
        id: String = "US",
        name: String = "United States",
        code: String = "US",
        emoji: String = "🇺🇸",
        continent: String? = "North America"
    ) -> Country {
        Country(id: id, name: name, code: code, emoji: emoji, continent: continent)
    }
    
    /// Creates a test country detail with default values.
    static func makeTestCountryDetail(
        id: String = "US",
        name: String = "United States",
        nativeName: String? = "United States of America",
        code: String = "US",
        emoji: String = "🇺🇸",
        continent: String? = "North America",
        capital: String? = "Washington, D.C.",
        currency: String? = "USD",
        languages: [String] = ["English"]
    ) -> CountryDetail {
        CountryDetail(
            id: id,
            name: name,
            nativeName: nativeName,
            code: code,
            emoji: emoji,
            continent: continent,
            capital: capital,
            currency: currency,
            languages: languages
        )
    }
    
    /// Creates a test country list.
    static func makeTestCountries() -> [Country] {
        [
            makeTestCountry(id: "US", name: "United States", code: "US", emoji: "🇺🇸", continent: "North America"),
            makeTestCountry(id: "GB", name: "United Kingdom", code: "GB", emoji: "🇬🇧", continent: "Europe"),
            makeTestCountry(id: "JP", name: "Japan", code: "JP", emoji: "🇯🇵", continent: "Asia"),
            makeTestCountry(id: "FR", name: "France", code: "FR", emoji: "🇫🇷", continent: "Europe"),
            makeTestCountry(id: "DE", name: "Germany", code: "DE", emoji: "🇩🇪", continent: "Europe")
        ]
    }
    
    /// Waits for an async expectation with timeout.
    static func waitForAsync(
        timeout: TimeInterval = 5.0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let expectation = XCTestExpectation(description: "Async operation")
        expectation.fulfill()
        _ = XCTWaiter.wait(for: [expectation], timeout: timeout)
    }
}

/// Extension to XCTestCase for common assertions.
extension XCTestCase {
    /// Asserts that an error is of a specific type.
    func assertError<T: Error>(
        _ error: Error,
        isType type: T.Type,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let expectedType = String(describing: type)
        let actualTypeName = String(describing: Mirror(reflecting: error).subjectType)
        XCTAssertTrue(error is T, "Expected error of type \(expectedType), got \(actualTypeName)", file: file, line: line)
    }
    
    /// Asserts that a value is not nil and returns it.
    func assertNotNil<T>(
        _ value: T?,
        message: String = "Expected non-nil value",
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> T {
        guard let value = value else {
            XCTFail(message, file: file, line: line)
            fatalError(message)
        }
        return value
    }
}

