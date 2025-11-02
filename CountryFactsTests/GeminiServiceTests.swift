//  GeminiServiceTests.swift
//  CountryFactsTests
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import XCTest
@testable import CountryFacts

/// Unit tests for GeminiService.
@MainActor
final class GeminiServiceTests: XCTestCase {
    var sut: GeminiService!
    var mockSession: URLSession!
    let testAPIKey = "test_api_key_123"
    let testBaseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent"
    
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(MockURLProtocol.self)
        mockSession = URLSession(configuration: .mock)
        sut = GeminiService(
            apiKey: testAPIKey,
            session: mockSession,
            baseURL: testBaseURL,
            maxRetries: 2,
            retryDelay: 0.1
        )
    }
    
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        URLProtocol.unregisterClass(MockURLProtocol.self)
        sut = nil
        mockSession = nil
        super.tearDown()
    }
    
    // MARK: - Generate Fun Fact Tests
    
    func testGenerateFunFact_Success_ReturnsFunFact() async throws {
        // Given
        let country = TestHelpers.makeTestCountry()
        let expectedText = "The United States has more than 10,000 airports!"
        
        let responseData = createSuccessResponse(text: expectedText)
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, responseData)
        }
        
        // When
        let funFact = try await sut.generateFunFact(about: country)
        
        // Then
        XCTAssertEqual(funFact, expectedText)
    }
    
    func testGenerateFunFact_WithEmptyAPIKey_ThrowsInvalidAPIKeyError() async {
        // Given
        sut = GeminiService(apiKey: "", session: mockSession, baseURL: testBaseURL)
        let country = TestHelpers.makeTestCountry()
        
        // When/Then
        do {
            _ = try await sut.generateFunFact(about: country)
            XCTFail("Should throw invalidAPIKey error")
        } catch let error as LLMServiceError {
            if case .invalidAPIKey = error {
                // Expected
            } else {
                XCTFail("Expected invalidAPIKey, got \(error)")
            }
        } catch {
            XCTFail("Expected LLMServiceError, got \(error)")
        }
    }
    
    func testGenerateFunFact_NetworkError_ThrowsNetworkError() async {
        // Given
        let country = TestHelpers.makeTestCountry()
        let networkError = URLError(.notConnectedToInternet)
        
        MockURLProtocol.requestHandler = { _ in
            throw networkError
        }
        
        // When/Then
        do {
            _ = try await sut.generateFunFact(about: country)
            XCTFail("Should throw network error")
        } catch let error as LLMServiceError {
            if case .networkError = error {
                // Expected
            } else {
                XCTFail("Expected networkError, got \(error)")
            }
        } catch {
            XCTFail("Expected LLMServiceError, got \(error)")
        }
    }
    
    func testGenerateFunFact_Timeout_RetriesThenThrowsTimeout() async {
        // Given
        let country = TestHelpers.makeTestCountry()
        let timeoutError = URLError(.timedOut)
        var callCount = 0
        
        MockURLProtocol.requestHandler = { _ in
            callCount += 1
            throw timeoutError
        }
        
        // When/Then
        do {
            _ = try await sut.generateFunFact(about: country)
            XCTFail("Should throw timeout error after retries")
        } catch let error as LLMServiceError {
            if case .timeout = error {
                // Expected after retries exhausted
                XCTAssertGreaterThanOrEqual(callCount, 2, "Should retry at least once")
            } else {
                XCTFail("Expected timeout, got \(error)")
            }
        } catch {
            XCTFail("Expected LLMServiceError, got \(error)")
        }
    }
    
    func testGenerateFunFact_RateLimit_RetriesThenThrowsRateLimitError() async {
        // Given
        let country = TestHelpers.makeTestCountry()
        let errorResponse = createErrorResponse(message: "Rate limit exceeded")
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 429,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, errorResponse)
        }
        
        // When/Then
        do {
            _ = try await sut.generateFunFact(about: country)
            XCTFail("Should throw rate limit error after retries")
        } catch let error as LLMServiceError {
            if case .rateLimitExceeded = error {
                // Expected after retries exhausted
            } else {
                XCTFail("Expected rateLimitExceeded, got \(error)")
            }
        } catch {
            XCTFail("Expected LLMServiceError, got \(error)")
        }
    }
    
    func testGenerateFunFact_ServiceUnavailable_RetriesThenThrowsServiceUnavailable() async {
        // Given
        let country = TestHelpers.makeTestCountry()
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 503,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        
        // When/Then
        do {
            _ = try await sut.generateFunFact(about: country)
            XCTFail("Should throw service unavailable error after retries")
        } catch let error as LLMServiceError {
            if case .serviceUnavailable = error {
                // Expected after retries exhausted
            } else {
                XCTFail("Expected serviceUnavailable, got \(error)")
            }
        } catch {
            XCTFail("Expected LLMServiceError, got \(error)")
        }
    }
    
    func testGenerateFunFact_InvalidAPIKey_ThrowsInvalidAPIKeyError() async {
        // Given
        let country = TestHelpers.makeTestCountry()
        let errorResponse = createErrorResponse(message: "API key not valid")
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 403,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, errorResponse)
        }
        
        // When/Then
        do {
            _ = try await sut.generateFunFact(about: country)
            XCTFail("Should throw invalidAPIKey error")
        } catch let error as LLMServiceError {
            if case .invalidAPIKey = error {
                // Expected
            } else {
                XCTFail("Expected invalidAPIKey, got \(error)")
            }
        } catch {
            XCTFail("Expected LLMServiceError, got \(error)")
        }
    }
    
    func testGenerateFunFact_QuotaExceeded_ThrowsQuotaExceededError() async {
        // Given
        let country = TestHelpers.makeTestCountry()
        let errorResponse = createErrorResponse(message: "Quota exceeded for quota metric")
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 403,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, errorResponse)
        }
        
        // When/Then
        do {
            _ = try await sut.generateFunFact(about: country)
            XCTFail("Should throw quotaExceeded error")
        } catch let error as LLMServiceError {
            if case .quotaExceeded = error {
                // Expected
            } else {
                XCTFail("Expected quotaExceeded, got \(error)")
            }
        } catch {
            XCTFail("Expected LLMServiceError, got \(error)")
        }
    }
    
    func testGenerateFunFact_EmptyResponse_ThrowsNoDataError() async {
        // Given
        let country = TestHelpers.makeTestCountry()
        let emptyResponse = GeminiGenerateContentResponse(candidates: nil, promptFeedback: nil)
        let responseData = try! JSONEncoder().encode(emptyResponse)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, responseData)
        }
        
        // When/Then
        do {
            _ = try await sut.generateFunFact(about: country)
            XCTFail("Should throw noData error")
        } catch let error as LLMServiceError {
            if case .noData = error {
                // Expected
            } else {
                XCTFail("Expected noData, got \(error)")
            }
        } catch {
            XCTFail("Expected LLMServiceError, got \(error)")
        }
    }
    
    // MARK: - Answer Question Tests
    
    func testAnswerQuestion_Success_ReturnsAnswer() async throws {
        // Given
        let question = "What is the capital?"
        let context = "Country: United States (🇺🇸)\nCapital: Washington, D.C."
        let expectedAnswer = "The capital of United States is Washington, D.C."
        
        let responseData = createSuccessResponse(text: expectedAnswer)
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, responseData)
        }
        
        // When
        let answer = try await sut.answerQuestion(question, context: context)
        
        // Then
        XCTAssertEqual(answer, expectedAnswer)
    }
    
    func testAnswerQuestion_NetworkError_ThrowsNetworkError() async {
        // Given
        let question = "What is the capital?"
        let context = "Country: United States"
        let networkError = URLError(.notConnectedToInternet)
        
        MockURLProtocol.requestHandler = { _ in
            throw networkError
        }
        
        // When/Then
        do {
            _ = try await sut.answerQuestion(question, context: context)
            XCTFail("Should throw network error")
        } catch let error as LLMServiceError {
            if case .networkError = error {
                // Expected
            } else {
                XCTFail("Expected networkError, got \(error)")
            }
        } catch {
            XCTFail("Expected LLMServiceError, got \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func createSuccessResponse(text: String) -> Data {
        let response = GeminiGenerateContentResponse(
            candidates: [
                GeminiGenerateContentResponse.GeminiCandidate(
                    content: GeminiGenerateContentResponse.GeminiContent(
                        parts: [
                            GeminiGenerateContentResponse.GeminiPart(text: text)
                        ]
                    ),
                    finishReason: nil
                )
            ],
            promptFeedback: nil
        )
        return try! JSONEncoder().encode(response)
    }
    
    private func createErrorResponse(message: String) -> Data {
        let errorResponse = GeminiErrorResponse(
            error: GeminiErrorResponse.GeminiError(
                code: nil,
                message: message,
                status: nil
            )
        )
        return try! JSONEncoder().encode(errorResponse)
    }
}


