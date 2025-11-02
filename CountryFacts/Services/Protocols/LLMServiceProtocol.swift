//  LLMServiceProtocol.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import Foundation

/// Protocol defining the interface for LLM (Large Language Model) services.
///
/// This protocol allows for easy testing and swapping of implementations.
/// Use `GeminiService` for production and `MockLLMService` for testing.
protocol LLMServiceProtocol {
    /// Generates a fun fact about a specific country.
    ///
    /// - Parameter country: The country to generate a fun fact about
    /// - Returns: A fun fact string about the country
    /// - Throws: `LLMServiceError` if the request fails
    func generateFunFact(about country: Country) async throws -> String
    
    /// Answers a question about a country using context information.
    ///
    /// - Parameters:
    ///   - question: The user's question
    ///   - context: Context information about the country (name, details, etc.)
    /// - Returns: An answer string to the question
    /// - Throws: `LLMServiceError` if the request fails
    func answerQuestion(_ question: String, context: String) async throws -> String
}

