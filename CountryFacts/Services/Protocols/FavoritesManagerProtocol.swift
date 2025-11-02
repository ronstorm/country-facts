//  FavoritesManagerProtocol.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import Foundation

/// Protocol defining the interface for favorites management.
protocol FavoritesManagerProtocol {
    /// Checks if a country is favorited.
    /// - Parameter countryCode: The country code to check
    /// - Returns: `true` if the country is favorited, `false` otherwise
    func isFavorite(countryCode: String) -> Bool
    
    /// Adds a country to favorites.
    /// - Parameter countryCode: The country code to add
    func addFavorite(countryCode: String)
    
    /// Removes a country from favorites.
    /// - Parameter countryCode: The country code to remove
    func removeFavorite(countryCode: String)
    
    /// Toggles the favorite status of a country.
    /// - Parameter countryCode: The country code to toggle
    /// - Returns: `true` if the country is now favorited, `false` if it was removed
    func toggleFavorite(countryCode: String) -> Bool
    
    /// Gets all favorited country codes.
    /// - Returns: An array of favorited country codes
    func getAllFavorites() -> [String]
    
    /// Clears all favorites.
    func clearAll()
}

