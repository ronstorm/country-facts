//  CountryServiceProtocol.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import Foundation

/// Protocol defining the interface for country data services.
///
/// This protocol allows for easy testing and swapping of implementations.
/// Use `CountryService` for production and `MockCountryService` for testing.
protocol CountryServiceProtocol {
    /// Fetches a list of all countries with basic information.
    ///
    /// - Returns: An array of `Country` objects with basic information
    /// - Throws: `CountryServiceError` if the request fails
    func fetchCountries() async throws -> [Country]
    
    /// Fetches detailed information for a specific country.
    ///
    /// - Parameter code: The ISO 3166-1 alpha-2 country code (e.g., "US", "GB")
    /// - Returns: A `CountryDetail` object with comprehensive information
    /// - Throws: `CountryServiceError` if the request fails or country is not found
    func fetchCountryDetails(code: String) async throws -> CountryDetail
}

