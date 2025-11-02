//  CountryDetailView.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import SwiftUI

/// Detail view displaying comprehensive information about a selected country.
struct CountryDetailView: View {
    @State private var viewModel: CountryDetailViewModel
    
    let country: Country
    
    /// Initializes the detail view with a country and required services.
    ///
    /// - Parameters:
    ///   - country: The country to display details for
    ///   - countryService: The service to use for fetching country details
    ///   - llmService: The service to use for generating fun facts
    init(
        country: Country,
        countryService: CountryServiceProtocol,
        llmService: LLMServiceProtocol
    ) {
        self.country = country
        _viewModel = State(
            wrappedValue: CountryDetailViewModel(
                countryCode: country.code,
                countryService: countryService,
                llmService: llmService
            )
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Section
                headerSection
                
                // Fun Fact Card - Always show (user can generate on demand)
                FunFactCard(
                    funFact: viewModel.funFact,
                    isLoading: viewModel.isLoadingFunFact,
                    errorMessage: viewModel.funFactError,
                    onRetry: {
                        Task {
                            await viewModel.regenerateFunFact()
                        }
                    },
                    onGenerate: {
                        Task {
                            await viewModel.regenerateFunFact()
                        }
                    }
                )
                .padding(.horizontal, 16)
                
                // Q&A Section
                QuestionAnswerView(
                    questionText: $viewModel.questionText,
                    answer: viewModel.answer,
                    isLoading: viewModel.isLoadingAnswer,
                    errorMessage: viewModel.answerError,
                    questionHistory: viewModel.questionHistory,
                    onAsk: {
                        Task {
                            await viewModel.askQuestion()
                        }
                    },
                    onClearHistory: {
                        viewModel.clearHistory()
                    }
                )
                .padding(.horizontal, 16)
                
                // Information Section
                if let countryDetail = viewModel.country {
                    informationSection(for: countryDetail)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 24)
        }
        .navigationTitle(country.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    _ = viewModel.toggleFavorite()
                }) {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(viewModel.isFavorite ? .red : .primary)
                        .symbolEffect(.bounce, value: viewModel.isFavorite)
                }
            }
        }
        .refreshable {
            await viewModel.loadCountryDetails()
        }
        .task {
            await viewModel.loadCountryDetails()
        }
    }
    
    // MARK: - View Components
    
    /// Header section with flag emoji and country name.
    private var headerSection: some View {
        VStack(spacing: 16) {
            if let countryDetail = viewModel.country {
                Text(countryDetail.emoji)
                    .font(.system(size: 100))
                
                VStack(spacing: 4) {
                    Text(countryDetail.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    if let nativeName = countryDetail.nativeName, nativeName != countryDetail.name {
                        Text(nativeName)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                // Loading placeholder
                Text(country.emoji)
                    .font(.system(size: 100))
                
                Text(country.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                if viewModel.isLoadingCountry {
                    ProgressView()
                        .padding(.top, 8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
    
    /// Information section displaying country details.
    private func informationSection(for countryDetail: CountryDetail) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Information")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            VStack(alignment: .leading, spacing: 0) {
                InformationRow(label: "Capital", value: countryDetail.capitalDisplay)
                
                Divider()
                    .padding(.vertical, 4)
                
                InformationRow(label: "Currency", value: countryDetail.currencyDisplay)
                
                Divider()
                    .padding(.vertical, 4)
                
                InformationRow(label: "Languages", value: countryDetail.languagesDisplay)
                
                Divider()
                    .padding(.vertical, 4)
                
                if let continent = countryDetail.continent {
                    InformationRow(label: "Continent", value: continent)
                    
                    Divider()
                        .padding(.vertical, 4)
                }
                
                InformationRow(label: "Country Code", value: countryDetail.code)
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CountryDetailView(
            country: Country(
                id: "US",
                name: "United States",
                code: "US",
                emoji: "🇺🇸",
                continent: "North America"
            ),
            countryService: MockCountryService(),
            llmService: MockLLMService()
        )
    }
}

