//  CountryDetail.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import Foundation

/// Represents detailed information about a country.
struct CountryDetail: Identifiable, Codable, Sendable {
    let id: String
    let name: String
    let nativeName: String?
    let code: String
    let emoji: String
    let continent: String?
    let capital: String?
    let currency: String?
    let languages: [String]
}

// MARK: - Extensions

extension CountryDetail {
    /// Display name combining emoji and name.
    var displayName: String {
        "\(emoji) \(name)"
    }
    
    /// Formatted languages string.
    var languagesDisplay: String {
        languages.isEmpty ? "N/A" : languages.joined(separator: ", ")
    }
    
    /// Formatted currency display.
    var currencyDisplay: String {
        currency ?? "N/A"
    }
    
    /// Formatted capital display.
    var capitalDisplay: String {
        capital ?? "N/A"
    }
}

