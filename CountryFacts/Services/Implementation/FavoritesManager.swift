//  FavoritesManager.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import Foundation

/// Notification name for when favorites change.
extension Notification.Name {
    static let favoritesDidChange = Notification.Name("com.amitsen.CountryFacts.favoritesDidChange")
}

/// Manages user's favorite countries using UserDefaults for persistence.
final class FavoritesManager: FavoritesManagerProtocol {
    // MARK: - Properties
    
    private let userDefaults: UserDefaults
    private let favoritesKey = "com.amitsen.CountryFacts.favorites"
    
    // MARK: - Initialization
    
    /// Initializes the favorites manager.
    ///
    /// - Parameter userDefaults: The UserDefaults instance to use. Defaults to `.standard`.
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - FavoritesManagerProtocol
    
    func isFavorite(countryCode: String) -> Bool {
        let favorites = getFavorites()
        return favorites.contains(countryCode)
    }
    
    func addFavorite(countryCode: String) {
        var favorites = getFavorites()
        if !favorites.contains(countryCode) {
            favorites.append(countryCode)
            saveFavorites(favorites)
            notifyFavoritesChanged()
        }
    }
    
    func removeFavorite(countryCode: String) {
        var favorites = getFavorites()
        favorites.removeAll { $0 == countryCode }
        saveFavorites(favorites)
        notifyFavoritesChanged()
    }
    
    func toggleFavorite(countryCode: String) -> Bool {
        if isFavorite(countryCode: countryCode) {
            removeFavorite(countryCode: countryCode)
            return false
        } else {
            addFavorite(countryCode: countryCode)
            return true
        }
    }
    
    func getAllFavorites() -> [String] {
        return getFavorites()
    }
    
    func clearAll() {
        saveFavorites([])
        notifyFavoritesChanged()
    }
    
    // MARK: - Private Helpers
    
    /// Retrieves the favorites array from UserDefaults.
    private func getFavorites() -> [String] {
        return userDefaults.stringArray(forKey: favoritesKey) ?? []
    }
    
    /// Saves the favorites array to UserDefaults.
    private func saveFavorites(_ favorites: [String]) {
        userDefaults.set(favorites, forKey: favoritesKey)
    }
    
    /// Posts a notification when favorites change.
    private func notifyFavoritesChanged() {
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
    }
}

