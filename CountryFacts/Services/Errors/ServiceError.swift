//  ServiceError.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import Foundation

/// Generic service errors that can occur across different services.
enum ServiceError: Error, LocalizedError {
    case networkError(underlying: Error)
    case invalidResponse
    case noData
    case decodingError(underlying: Error)
    case unknownError(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let underlying):
            return "Unable to connect to the server. \(underlying.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .noData:
            return "No data received from server"
        case .decodingError(let underlying):
            return "Failed to parse server response. \(underlying.localizedDescription)"
        case .unknownError(let underlying):
            return "An unexpected error occurred. \(underlying.localizedDescription)"
        }
    }
}

