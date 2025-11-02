//  GeminiService.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import Foundation

/// Service for interacting with Google's Gemini API to generate fun facts and answer questions.
final class GeminiService: LLMServiceProtocol {
    // MARK: - Properties
    
    private let apiKey: String
    private let session: URLSession
    private let baseURL: String
    private let maxRetries: Int
    private let retryDelay: TimeInterval
    
    // MARK: - Initialization
    
    /// Initializes the Gemini service.
    ///
    /// - Parameters:
    ///   - apiKey: The Gemini API key. If not provided, uses `Configuration.geminiAPIKey`
    ///   - session: URLSession to use for network requests. Defaults to `.shared`
    ///   - baseURL: Base URL for the Gemini API. Defaults to `Configuration.geminiAPIEndpoint`
    ///   - maxRetries: Maximum number of retry attempts for transient failures. Defaults to 3
    ///   - retryDelay: Delay in seconds between retry attempts. Defaults to 1.0
    init(
        apiKey: String? = nil,
        session: URLSession = .shared,
        baseURL: String? = nil,
        maxRetries: Int = 3,
        retryDelay: TimeInterval = 1.0
    ) {
        let retrievedKey = apiKey ?? Configuration.geminiAPIKey
        self.apiKey = retrievedKey
        
        // Debug: Log API key status (only in debug builds)
        #if DEBUG
        Configuration.debugAPIKeyStatus()
        if retrievedKey.isEmpty {
            print("⚠️ WARNING: Gemini API key is empty!")
            print("   Please ensure GEMINI_API_KEY is set in Info.plist or Config.xcconfig")
        } else {
            print("✅ Gemini API key loaded successfully (length: \(retrievedKey.count))")
        }
        #endif
        
        self.session = session
        self.baseURL = baseURL ?? Configuration.geminiAPIEndpoint
        self.maxRetries = maxRetries
        self.retryDelay = retryDelay
    }
    
    // MARK: - LLMServiceProtocol
    
    func generateFunFact(about country: Country) async throws -> String {
        let request = GeminiGenerateContentRequest.funFactRequest(for: country)
        return try await performRequest(request, retryCount: 0)
    }
    
    func answerQuestion(_ question: String, context: String) async throws -> String {
        let request = GeminiGenerateContentRequest.questionRequest(question: question, context: context)
        return try await performRequest(request, retryCount: 0)
    }
    
    // MARK: - Private Helpers
    
    /// Performs the API request with retry logic.
    private func performRequest(_ request: GeminiGenerateContentRequest, retryCount: Int) async throws -> String {
        // Validate API key
        guard !apiKey.isEmpty else {
            throw LLMServiceError.invalidAPIKey
        }
        
        // Build URL with API key
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw LLMServiceError.invalidRequest("Invalid base URL")
        }
        urlComponents.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        
        guard let url = urlComponents.url else {
            throw LLMServiceError.invalidRequest("Failed to construct URL")
        }
        
        // Create HTTP request
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "POST"
        httpRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode request body
        do {
            let encoder = JSONEncoder()
            // Gemini API uses camelCase for JSON (standard Google API format)
            httpRequest.httpBody = try encoder.encode(request)
        } catch {
            throw LLMServiceError.decodingError(underlying: error)
        }
        
        // Perform request
        do {
            let (data, response) = try await session.data(for: httpRequest)
            
            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw LLMServiceError.invalidResponse
            }
            
            // Handle HTTP status codes
            switch httpResponse.statusCode {
            case 200...299:
                // Success - parse response
                return try parseResponse(data)
                
            case 429:
                // Rate limit exceeded
                if retryCount < maxRetries {
                    try await Task.sleep(nanoseconds: UInt64(retryDelay * Double(retryCount + 1) * 1_000_000_000))
                    return try await performRequest(request, retryCount: retryCount + 1)
                }
                throw LLMServiceError.rateLimitExceeded
                
            case 503, 502, 504:
                // Service unavailable - retry
                if retryCount < maxRetries {
                    try await Task.sleep(nanoseconds: UInt64(retryDelay * Double(retryCount + 1) * 1_000_000_000))
                    return try await performRequest(request, retryCount: retryCount + 1)
                }
                throw LLMServiceError.serviceUnavailable
                
            case 400:
                // Bad request - parse error details
                if let errorResponse = try? JSONDecoder().decode(GeminiErrorResponse.self, from: data) {
                    throw LLMServiceError.invalidRequest(errorResponse.error.message ?? "Invalid request")
                }
                throw LLMServiceError.invalidRequest("Bad request")
                
            case 403:
                // Forbidden - likely quota exceeded or invalid API key
                if let errorResponse = try? JSONDecoder().decode(GeminiErrorResponse.self, from: data),
                   let message = errorResponse.error.message,
                   message.lowercased().contains("quota") {
                    throw LLMServiceError.quotaExceeded
                }
                throw LLMServiceError.invalidAPIKey
                
            default:
                // Other errors
                if let errorResponse = try? JSONDecoder().decode(GeminiErrorResponse.self, from: data) {
                    throw LLMServiceError.unknownError(
                        underlying: NSError(
                            domain: "GeminiService",
                            code: httpResponse.statusCode,
                            userInfo: [NSLocalizedDescriptionKey: errorResponse.error.message ?? "Unknown error"]
                        )
                    )
                }
                throw LLMServiceError.unknownError(
                    underlying: NSError(
                        domain: "GeminiService",
                        code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode)"]
                    )
                )
            }
        } catch let urlError as URLError {
            // Handle URL errors including timeout
            switch urlError.code {
            case .timedOut:
                if retryCount < maxRetries {
                    try await Task.sleep(nanoseconds: UInt64(retryDelay * Double(retryCount + 1) * 1_000_000_000))
                    return try await performRequest(request, retryCount: retryCount + 1)
                }
                throw LLMServiceError.timeout
            case .notConnectedToInternet, .networkConnectionLost:
                if retryCount < maxRetries {
                    try await Task.sleep(nanoseconds: UInt64(retryDelay * Double(retryCount + 1) * 1_000_000_000))
                    return try await performRequest(request, retryCount: retryCount + 1)
                }
                throw LLMServiceError.networkError(underlying: urlError)
            default:
                throw LLMServiceError.networkError(underlying: urlError)
            }
        } catch let llmError as LLMServiceError {
            // Re-throw LLM service errors
            throw llmError
        } catch {
            // Handle any other errors
            throw LLMServiceError.unknownError(underlying: error)
        }
    }
    
    /// Parses the response data into a text string.
    private func parseResponse(_ data: Data) throws -> String {
        guard !data.isEmpty else {
            throw LLMServiceError.noData
        }
        
        do {
            let decoder = JSONDecoder()
            // Gemini API uses camelCase for JSON (standard Google API format)
            let response = try decoder.decode(GeminiGenerateContentResponse.self, from: data)
            
            guard let text = response.generatedText, !text.isEmpty else {
                // Check if content was blocked
                if let feedback = response.promptFeedback,
                   let blockReason = feedback.blockReason {
                    throw LLMServiceError.invalidRequest("Content blocked: \(blockReason)")
                }
                throw LLMServiceError.noData
            }
            
            return text
        } catch let error as LLMServiceError {
            throw error
        } catch {
            throw LLMServiceError.decodingError(underlying: error)
        }
    }
}

