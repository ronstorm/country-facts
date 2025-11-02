//  MockCountryService.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import Foundation

/// Mock implementation of CountryServiceProtocol for testing purposes.
nonisolated final class MockCountryService: CountryServiceProtocol {
    // MARK: - Properties
    
    /// Mock countries data.
    nonisolated var mockCountries: [Country] = []
    
    /// Mock country details data.
    nonisolated var mockCountryDetails: [String: CountryDetail] = [:]
    
    /// Whether to simulate an error when fetching countries.
    nonisolated var shouldThrowErrorOnFetchCountries = false
    
    /// Whether to simulate an error when fetching country details.
    nonisolated var shouldThrowErrorOnFetchDetails = false
    
    /// Error to throw when simulating errors.
    nonisolated var mockError: CountryServiceError = .unknownError(underlying: NSError(domain: "MockError", code: 999))
    
    /// Delay in seconds before returning mock data (for testing loading states).
    nonisolated var delay: TimeInterval = 0
    
    // MARK: - Initialization
    
    /// Initializes the mock service with default test data.
    init() {
        setupDefaultMockData()
    }
    
    // MARK: - CountryServiceProtocol
    
    func fetchCountries() async throws -> [Country] {
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if shouldThrowErrorOnFetchCountries {
            throw mockError
        }
        
        return mockCountries
    }
    
    func fetchCountryDetails(code: String) async throws -> CountryDetail {
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if shouldThrowErrorOnFetchDetails {
            throw mockError
        }
        
        guard let countryDetail = mockCountryDetails[code] else {
            throw CountryServiceError.countryNotFound(code: code)
        }
        
        return countryDetail
    }
    
    // MARK: - Helper Methods
    
    /// Sets up default mock data for testing.
    private func setupDefaultMockData() {
        mockCountries = [
            Country(
                id: "US",
                name: "United States",
                code: "US",
                emoji: "🇺🇸",
                continent: "North America"
            ),
            Country(
                id: "GB",
                name: "United Kingdom",
                code: "GB",
                emoji: "🇬🇧",
                continent: "Europe"
            ),
            Country(
                id: "JP",
                name: "Japan",
                code: "JP",
                emoji: "🇯🇵",
                continent: "Asia"
            )
        ]
        
        mockCountryDetails = [
            "US": CountryDetail(
                id: "US",
                name: "United States",
                nativeName: "United States of America",
                code: "US",
                emoji: "🇺🇸",
                continent: "North America",
                capital: "Washington, D.C.",
                currency: "USD",
                languages: ["English"]
            ),
            "GB": CountryDetail(
                id: "GB",
                name: "United Kingdom",
                nativeName: "United Kingdom",
                code: "GB",
                emoji: "🇬🇧",
                continent: "Europe",
                capital: "London",
                currency: "GBP",
                languages: ["English"]
            ),
            "JP": CountryDetail(
                id: "JP",
                name: "Japan",
                nativeName: "日本",
                code: "JP",
                emoji: "🇯🇵",
                continent: "Asia",
                capital: "Tokyo",
                currency: "JPY",
                languages: ["Japanese"]
            )
        ]
    }
}

