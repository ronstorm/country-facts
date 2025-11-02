//  CountryListView.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import SwiftUI

/// Main view displaying a scrollable list of countries with search functionality.
struct CountryListView: View {
    @State private var viewModel: CountryListViewModel
    
    let countryService: CountryServiceProtocol
    let llmService: LLMServiceProtocol
    
    /// Initializes the view with required services.
    ///
    /// - Parameters:
    ///   - countryService: The service to use for fetching countries.
    ///   - llmService: The service to use for generating fun facts.
    ///   Use `CountryService()` and `GeminiService()` for production or `MockCountryService()` and `MockLLMService()` for testing.
    init(
        countryService: CountryServiceProtocol,
        llmService: LLMServiceProtocol
    ) {
        self.countryService = countryService
        self.llmService = llmService
        _viewModel = State(wrappedValue: CountryListViewModel(countryService: countryService))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.countries.isEmpty {
                    // Initial loading state
                    LoadingView(message: "Loading countries...")
                } else if let errorMessage = viewModel.errorMessage, viewModel.countries.isEmpty {
                    // Error state when no countries loaded
                    ErrorView(message: errorMessage) {
                        Task {
                            await viewModel.loadCountries()
                        }
                    }
                } else if viewModel.shouldShowEmptyState {
                    // Empty state (no countries available)
                    EmptyStateView(
                        icon: "🌍",
                        title: "No countries available",
                        message: "Pull down to refresh"
                    )
                } else if viewModel.shouldShowNoSearchResults {
                    // No search results
                    EmptyStateView(
                        icon: "🔍",
                        title: "No countries found",
                        message: "Try adjusting your search"
                    )
                } else {
                    // Country list
                    List {
                        ForEach(viewModel.filteredCountries) { country in
                            NavigationLink(value: country) {
                                CountryRow(
                                    country: country,
                                    isFavorite: viewModel.isFavorite(countryCode: country.code)
                                )
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Countries")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.toggleFavoritesFilter()
                    }) {
                        Image(systemName: viewModel.isFavoritesFilterActive ? "heart.fill" : "heart")
                            .foregroundStyle(viewModel.isFavoritesFilterActive ? .red : .primary)
                    }
                }
            }
            .searchable(text: $viewModel.searchQuery, prompt: "Search countries")
            .refreshable {
                await viewModel.refresh()
            }
            .navigationDestination(for: Country.self) { country in
                CountryDetailView(
                    country: country,
                    countryService: countryService,
                    llmService: llmService
                )
            }
        }
        .task {
            // Load countries when view appears
            if viewModel.countries.isEmpty {
                await viewModel.loadCountries()
            }
        }
        .onAppear {
            // Refresh favorites state when returning from detail view
            // This ensures the heart icons update after toggling favorites in detail view
            viewModel.refreshFavoritesState()
        }
    }
}

// MARK: - Preview

#Preview {
    CountryListView(
        countryService: MockCountryService(),
        llmService: MockLLMService()
    )
}

