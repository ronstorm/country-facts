//  LLMServiceErrorTests.swift
//  CountryFactsTests
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import XCTest
@testable import CountryFacts

/// Unit tests for LLMServiceError.
final class LLMServiceErrorTests: XCTestCase {
    
    // MARK: - Error Description Tests
    
    func testInvalidAPIKey_ProvidesUserFriendlyMessage() {
        // Given
        let error = LLMServiceError.invalidAPIKey
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertEqual(description, "Invalid API key. Please check your Gemini API key configuration.")
    }
    
    func testNetworkError_ProvidesUserFriendlyMessage() {
        // Given
        let underlyingError = NSError(domain: "TestDomain", code: 123)
        let error = LLMServiceError.networkError(underlying: underlyingError)
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertNotNil(description)
        XCTAssertTrue(description?.contains("Unable to connect") ?? false)
    }
    
    func testInvalidResponse_ProvidesUserFriendlyMessage() {
        // Given
        let error = LLMServiceError.invalidResponse
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertEqual(description, "Invalid response from service. Please try again later.")
    }
    
    func testRateLimitExceeded_ProvidesUserFriendlyMessage() {
        // Given
        let error = LLMServiceError.rateLimitExceeded
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertEqual(description, "Rate limit exceeded. Please wait a moment and try again.")
    }
    
    func testQuotaExceeded_ProvidesUserFriendlyMessage() {
        // Given
        let error = LLMServiceError.quotaExceeded
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertEqual(description, "API quota exceeded. Please check your API usage limits.")
    }
    
    func testServiceUnavailable_ProvidesUserFriendlyMessage() {
        // Given
        let error = LLMServiceError.serviceUnavailable
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertEqual(description, "Service is currently unavailable. Please try again later.")
    }
    
    func testTimeout_ProvidesUserFriendlyMessage() {
        // Given
        let error = LLMServiceError.timeout
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertEqual(description, "Request timed out. Please check your internet connection and try again.")
    }
    
    func testInvalidRequest_ProvidesUserFriendlyMessage() {
        // Given
        let error = LLMServiceError.invalidRequest("Bad request format")
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertEqual(description, "Invalid request: Bad request format")
    }
    
    // MARK: - Retry Logic Tests
    
    func testIsRetryable_NetworkError_ReturnsTrue() {
        // Given
        let error = LLMServiceError.networkError(underlying: NSError(domain: "Test", code: 1))
        
        // Then
        XCTAssertTrue(error.isRetryable)
    }
    
    func testIsRetryable_ServiceUnavailable_ReturnsTrue() {
        // Given
        let error = LLMServiceError.serviceUnavailable
        
        // Then
        XCTAssertTrue(error.isRetryable)
    }
    
    func testIsRetryable_RateLimitExceeded_ReturnsTrue() {
        // Given
        let error = LLMServiceError.rateLimitExceeded
        
        // Then
        XCTAssertTrue(error.isRetryable)
    }
    
    func testIsRetryable_Timeout_ReturnsTrue() {
        // Given
        let error = LLMServiceError.timeout
        
        // Then
        XCTAssertTrue(error.isRetryable)
    }
    
    func testIsRetryable_InvalidAPIKey_ReturnsFalse() {
        // Given
        let error = LLMServiceError.invalidAPIKey
        
        // Then
        XCTAssertFalse(error.isRetryable)
    }
    
    func testIsRetryable_QuotaExceeded_ReturnsFalse() {
        // Given
        let error = LLMServiceError.quotaExceeded
        
        // Then
        XCTAssertFalse(error.isRetryable)
    }
    
    func testIsRetryable_InvalidRequest_ReturnsFalse() {
        // Given
        let error = LLMServiceError.invalidRequest("Bad request")
        
        // Then
        XCTAssertFalse(error.isRetryable)
    }
    
    // MARK: - Error Conformance Tests
    
    func testLLMServiceError_ConformsToError() {
        // Given
        let error: Error = LLMServiceError.invalidAPIKey
        
        // Then
        XCTAssertNotNil(error as? LLMServiceError)
    }
    
    func testLLMServiceError_ConformsToLocalizedError() {
        // Given
        let error: LocalizedError = LLMServiceError.networkError(underlying: NSError(domain: "Test", code: 1))
        
        // When
        let description = error.errorDescription
        
        // Then
        XCTAssertNotNil(description)
    }
}

