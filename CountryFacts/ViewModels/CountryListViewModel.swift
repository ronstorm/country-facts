//  CountryListViewModel.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import Foundation

/// ViewModel for managing the country list screen state and business logic.
@MainActor
@Observable
final class CountryListViewModel {
    // MARK: - Published State
    
    /// All countries fetched from the API.
    var countries: [Country] = []
    
    /// Whether countries are currently being loaded.
    var isLoading = false
    
    /// Error message to display to the user, if any.
    var errorMessage: String?
    
    /// Current search query entered by the user.
    var searchQuery = ""
    
    /// Whether to show only favorites.
    var showFavoritesOnly = false
    
    /// Trigger to force UI updates when favorites change.
    /// Incremented whenever favorites are toggled to trigger SwiftUI re-render.
    private var favoritesUpdateTrigger = 0
    
    // MARK: - Private Dependencies
    
    private let countryService: CountryServiceProtocol
    private let favoritesManager: FavoritesManagerProtocol
    
    // MARK: - Initialization
    
    /// Initializes the ViewModel with a country service.
    ///
    /// - Parameters:
    ///   - countryService: The service to use for fetching countries.
    ///     Use `CountryService()` for production or `MockCountryService()` for testing.
    ///   - favoritesManager: The favorites manager to use.
    ///     Use `FavoritesManager()` for production or `MockFavoritesManager()` for testing.
    init(
        countryService: CountryServiceProtocol,
        favoritesManager: FavoritesManagerProtocol = FavoritesManager()
    ) {
        self.countryService = countryService
        self.favoritesManager = favoritesManager
        
        // Listen for favorites changes
        NotificationCenter.default.addObserver(
            forName: .favoritesDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.favoritesUpdateTrigger += 1
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Refreshes the favorites state to trigger UI update.
    /// Call this when returning from detail view to ensure heart icons are up to date.
    func refreshFavoritesState() {
        favoritesUpdateTrigger += 1
    }
    
    // MARK: - Public Methods
    
    /// Loads the list of countries from the API.
    ///
    /// This method handles loading states and error management.
    /// Call this when the view appears or when pull-to-refresh is triggered.
    func loadCountries() async {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            let fetchedCountries = try await countryService.fetchCountries()
            countries = fetchedCountries.sorted { $0.name < $1.name }
            errorMessage = nil
        } catch {
            errorMessage = userFriendlyErrorMessage(for: error)
        }
    }
    
    /// Refreshes the country list.
    ///
    /// Convenience method for pull-to-refresh functionality.
    func refresh() async {
        await loadCountries()
    }
    
    /// Clears the current search query.
    func clearSearch() {
        searchQuery = ""
    }
    
    /// Toggles the favorite status of a country.
    /// - Parameter countryCode: The country code to toggle
    /// - Returns: `true` if the country is now favorited, `false` if it was removed
    func toggleFavorite(countryCode: String) -> Bool {
        let result = favoritesManager.toggleFavorite(countryCode: countryCode)
        // Trigger UI update by incrementing the trigger
        favoritesUpdateTrigger += 1
        return result
    }
    
    /// Checks if a country is favorited.
    /// - Parameter countryCode: The country code to check
    /// - Returns: `true` if the country is favorited, `false` otherwise
    func isFavorite(countryCode: String) -> Bool {
        // Access favoritesUpdateTrigger to ensure SwiftUI tracks this method
        _ = favoritesUpdateTrigger
        return favoritesManager.isFavorite(countryCode: countryCode)
    }
    
    /// Toggles the favorites filter.
    func toggleFavoritesFilter() {
        showFavoritesOnly.toggle()
    }
    
    // MARK: - Computed Properties
    
    /// Filtered countries based on the current search query.
    ///
    /// Filters by country name or continent (case-insensitive).
    /// Also filters by favorites if `showFavoritesOnly` is true.
    var filteredCountries: [Country] {
        // Access favoritesUpdateTrigger to ensure SwiftUI tracks changes to favorites
        _ = favoritesUpdateTrigger
        
        var countriesToFilter = countries
        
        // Filter by favorites if enabled
        if showFavoritesOnly {
            countriesToFilter = countriesToFilter.filter { country in
                favoritesManager.isFavorite(countryCode: country.code)
            }
        }
        
        // Filter by search query
        guard !searchQuery.isEmpty else {
            return countriesToFilter
        }
        
        let query = searchQuery.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return countriesToFilter
        }
        
        return countriesToFilter.filter { country in
            country.name.lowercased().contains(query) ||
            country.continent?.lowercased().contains(query) ?? false ||
            country.code.lowercased().contains(query)
        }
    }
    
    /// Whether there are any countries to display.
    var hasCountries: Bool {
        !countries.isEmpty
    }
    
    /// Whether the filtered results are empty (no matches for search).
    var hasFilteredResults: Bool {
        !filteredCountries.isEmpty
    }
    
    /// Whether to show an empty state message.
    var shouldShowEmptyState: Bool {
        !isLoading && countries.isEmpty && errorMessage == nil
    }
    
    /// Whether to show a "no search results" message.
    var shouldShowNoSearchResults: Bool {
        !isLoading && !countries.isEmpty && searchQuery.isEmpty == false && filteredCountries.isEmpty
    }
    
    /// Whether there are any favorite countries.
    var hasFavorites: Bool {
        !favoritesManager.getAllFavorites().isEmpty
    }
    
    /// Whether favorites filter is active.
    var isFavoritesFilterActive: Bool {
        showFavoritesOnly
    }
    
    // MARK: - Private Helpers
    
    /// Converts service errors into user-friendly error messages.
    private func userFriendlyErrorMessage(for error: Error) -> String {
        if let countryError = error as? CountryServiceError {
            return countryError.localizedDescription
        }
        
        // Generic error fallback
        return "Unable to load countries. Please check your internet connection and try again."
    }
}

