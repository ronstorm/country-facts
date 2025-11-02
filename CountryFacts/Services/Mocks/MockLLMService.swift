//  MockLLMService.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import Foundation

/// Mock implementation of LLMServiceProtocol for testing purposes.
nonisolated final class MockLLMService: LLMServiceProtocol {
    // MARK: - Properties
    
    /// Predefined fun facts to return for specific countries.
    nonisolated var mockFunFacts: [String: String] = [:]
    
    /// Default fun fact to return when no specific fact is set.
    nonisolated var defaultFunFact: String = "This is a fascinating country with rich history and culture."
    
    /// Predefined answers for questions.
    nonisolated var mockAnswers: [String: String] = [:]
    
    /// Default answer to return when no specific answer is set.
    nonisolated var defaultAnswer: String = "Based on the provided context, I can answer your question."
    
    /// Whether to simulate an error when generating fun facts.
    nonisolated var shouldThrowErrorOnFunFact = false
    
    /// Whether to simulate an error when answering questions.
    nonisolated var shouldThrowErrorOnQuestion = false
    
    /// Error to throw when simulating errors.
    nonisolated var mockError: LLMServiceError = .unknownError(underlying: NSError(domain: "MockError", code: 999))
    
    /// Delay in seconds before returning mock data (for testing loading states).
    nonisolated var delay: TimeInterval = 0
    
    // MARK: - Initialization
    
    /// Initializes the mock service with default test data.
    init() {
        setupDefaultMockData()
    }
    
    // MARK: - LLMServiceProtocol
    
    func generateFunFact(about country: Country) async throws -> String {
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if shouldThrowErrorOnFunFact {
            throw mockError
        }
        
        return mockFunFacts[country.code] ?? defaultFunFact
    }
    
    func answerQuestion(_ question: String, context: String) async throws -> String {
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if shouldThrowErrorOnQuestion {
            throw mockError
        }
        
        // Try to find a specific answer for the question
        let questionKey = question.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if let answer = mockAnswers[questionKey] {
            return answer
        }
        
        // Return default answer with context
        return "\(defaultAnswer) Context: \(context.prefix(100))..."
    }
    
    // MARK: - Helper Methods
    
    /// Sets up default mock data for testing.
    private func setupDefaultMockData() {
        mockFunFacts = [
            "US": "The United States has more than 10,000 airports, more than any other country in the world!",
            "GB": "The United Kingdom has no single written constitution - it's based on statutes, common law, and conventions.",
            "JP": "Japan has over 5.5 million vending machines, roughly one for every 23 people!",
            "FR": "France is the most visited country in the world, attracting over 89 million tourists annually.",
            "DE": "Germany has over 1,500 different types of bread, showcasing its rich baking tradition.",
            "CA": "Canada has the longest coastline in the world, stretching over 243,000 kilometers!",
            "AU": "Australia is home to the world's longest fence - the Dingo Fence stretches 5,614 kilometers."
        ]
        
        mockAnswers = [
            "what is the capital": "The capital city varies by country. Please check the country details.",
            "what is the population": "Population information can be found in the country's detailed statistics.",
            "what language": "The official languages are listed in the country information section."
        ]
    }
}

