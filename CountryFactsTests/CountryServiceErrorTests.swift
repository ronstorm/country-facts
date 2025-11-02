//  CountryServiceErrorTests.swift
//  CountryFactsTests
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import XCTest
@testable import CountryFacts

/// Unit tests for CountryServiceError.
final class CountryServiceErrorTests: XCTestCase {
    
    // MARK: - Error Description Tests
    
    func testNetworkError_ProvidesUserFriendlyMessage() {
        // Given
        let underlyingError = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        let error = CountryServiceError.networkError(underlying: underlyingError)
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertNotNil(description)
        XCTAssertTrue(description?.contains("Unable to connect") ?? false)
        // Note: The actual implementation doesn't include underlying error details in the message
    }
    
    func testInvalidResponse_ProvidesUserFriendlyMessage() {
        // Given
        let error = CountryServiceError.invalidResponse
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertEqual(description, "Invalid response from server. Please try again later.")
    }
    
    func testNoData_ProvidesUserFriendlyMessage() {
        // Given
        let error = CountryServiceError.noData
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertEqual(description, "No data received from server. Please try again.")
    }
    
    func testCountryNotFound_ProvidesUserFriendlyMessage() {
        // Given
        let error = CountryServiceError.countryNotFound(code: "XX")
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertNotNil(description)
        XCTAssertTrue(description?.contains("XX") ?? false)
        XCTAssertTrue(description?.contains("not found") ?? false)
    }
    
    func testDecodingError_ProvidesUserFriendlyMessage() {
        // Given
        let underlyingError = NSError(domain: "DecodingError", code: 456, userInfo: [NSLocalizedDescriptionKey: "Decoding failed"])
        let error = CountryServiceError.decodingError(underlying: underlyingError)
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertNotNil(description)
        XCTAssertTrue(description?.contains("Failed to parse") ?? false)
        // Note: The actual implementation doesn't include underlying error details in the message
    }
    
    func testUnknownError_ProvidesUserFriendlyMessage() {
        // Given
        let underlyingError = NSError(domain: "UnknownDomain", code: 789, userInfo: [NSLocalizedDescriptionKey: "Unknown issue"])
        let error = CountryServiceError.unknownError(underlying: underlyingError)
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertNotNil(description)
        XCTAssertTrue(description?.contains("An unexpected error occurred") ?? false)
        // Note: The actual implementation doesn't include underlying error details in the message
    }
    
    // MARK: - Error Conformance Tests
    
    func testCountryServiceError_ConformsToError() {
        // Given
        let error: Error = CountryServiceError.invalidResponse
        
        // Then
        XCTAssertNotNil(error as? CountryServiceError)
    }
    
    func testCountryServiceError_ConformsToLocalizedError() {
        // Given
        let error: LocalizedError = CountryServiceError.noData
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertNotNil(description)
    }
}

