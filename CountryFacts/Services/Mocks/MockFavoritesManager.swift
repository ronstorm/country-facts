//  MockFavoritesManager.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import Foundation

/// Mock implementation of FavoritesManagerProtocol for testing purposes.
final class MockFavoritesManager: FavoritesManagerProtocol {
    // MARK: - Properties
    
    /// Mock favorites storage.
    var mockFavorites: Set<String> = []
    
    // MARK: - FavoritesManagerProtocol
    
    func isFavorite(countryCode: String) -> Bool {
        mockFavorites.contains(countryCode)
    }
    
    func addFavorite(countryCode: String) {
        mockFavorites.insert(countryCode)
    }
    
    func removeFavorite(countryCode: String) {
        mockFavorites.remove(countryCode)
    }
    
    func toggleFavorite(countryCode: String) -> Bool {
        if mockFavorites.contains(countryCode) {
            mockFavorites.remove(countryCode)
            return false
        } else {
            mockFavorites.insert(countryCode)
            return true
        }
    }
    
    func getAllFavorites() -> [String] {
        Array(mockFavorites)
    }
    
    func clearAll() {
        mockFavorites.removeAll()
    }
}

