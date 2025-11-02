//  CountryServiceError.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import Foundation

/// Errors specific to country service operations.
enum CountryServiceError: Error, LocalizedError {
    case networkError(underlying: Error)
    case invalidResponse
    case noData
    case countryNotFound(code: String)
    case decodingError(underlying: Error)
    case timeout
    case unknownError(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .networkError(_):
            return "Unable to connect to the server. Please check your internet connection and try again."
        case .invalidResponse:
            return "Invalid response from server. Please try again later."
        case .noData:
            return "No data received from server. Please try again."
        case .countryNotFound(let code):
            return "Country with code '\(code)' not found"
        case .decodingError(_):
            return "Failed to parse server response. Please try again later."
        case .timeout:
            return "Request timed out. Please check your internet connection and try again."
        case .unknownError(_):
            return "An unexpected error occurred. Please try again later."
        }
    }
    
    /// Determines if the error is retryable.
    var isRetryable: Bool {
        switch self {
        case .networkError, .timeout, .noData:
            return true
        case .invalidResponse, .countryNotFound, .decodingError, .unknownError:
            return false
        }
    }
}

