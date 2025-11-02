//  Country.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import Foundation

/// Represents a country with basic information for list display.
struct Country: Identifiable, Codable, Sendable, Hashable {
    let id: String
    let name: String
    let code: String
    let emoji: String
    let continent: String?
}

// MARK: - Extensions

extension Country {
    /// Display name combining emoji and name.
    var displayName: String {
        "\(emoji) \(name)"
    }
}

