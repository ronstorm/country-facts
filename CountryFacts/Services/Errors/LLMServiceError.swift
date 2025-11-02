//  LLMServiceError.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import Foundation

/// Errors specific to LLM service operations.
enum LLMServiceError: Error, LocalizedError {
    case invalidAPIKey
    case networkError(underlying: Error)
    case invalidResponse
    case noData
    case decodingError(underlying: Error)
    case rateLimitExceeded
    case quotaExceeded
    case serviceUnavailable
    case timeout
    case invalidRequest(String)
    case unknownError(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key. Please check your Gemini API key configuration."
        case .networkError(_):
            return "Unable to connect to the service. Please check your internet connection and try again."
        case .invalidResponse:
            return "Invalid response from service. Please try again later."
        case .noData:
            return "No data received from service. Please try again."
        case .decodingError(_):
            return "Failed to parse service response. Please try again later."
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please wait a moment and try again."
        case .quotaExceeded:
            return "API quota exceeded. Please check your API usage limits."
        case .serviceUnavailable:
            return "Service is currently unavailable. Please try again later."
        case .timeout:
            return "Request timed out. Please check your internet connection and try again."
        case .invalidRequest(let message):
            return "Invalid request: \(message)"
        case .unknownError(_):
            return "An unexpected error occurred. Please try again later."
        }
    }
    
    /// Determines if the error is retryable.
    var isRetryable: Bool {
        switch self {
        case .networkError, .serviceUnavailable, .rateLimitExceeded, .timeout:
            return true
        case .invalidAPIKey, .quotaExceeded, .invalidRequest, .invalidResponse, .noData, .decodingError, .unknownError:
            return false
        }
    }
}

