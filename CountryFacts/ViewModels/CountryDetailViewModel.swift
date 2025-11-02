//  CountryDetailViewModel.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import Foundation

/// ViewModel for managing the country detail screen state and business logic.
@MainActor
@Observable
final class CountryDetailViewModel {
    // MARK: - Published State
    
    /// The detailed country information.
    var country: CountryDetail?
    
    /// The generated fun fact about the country.
    var funFact: String?
    
    /// Whether country details are currently being loaded.
    var isLoadingCountry = false
    
    /// Whether a fun fact is currently being generated.
    var isLoadingFunFact = false
    
    /// Error message to display to the user, if any.
    var errorMessage: String?
    
    /// Whether the fun fact generation failed.
    var funFactError: String?
    
    // MARK: - Q&A State
    
    /// The current question text entered by the user.
    var questionText = ""
    
    /// The answer to the current question.
    var answer: String?
    
    /// Whether an answer is currently being generated.
    var isLoadingAnswer = false
    
    /// Error message for Q&A feature, if any.
    var answerError: String?
    
    /// History of questions and answers.
    var questionHistory: [QuestionAnswer] = []
    
    /// Trigger to force UI updates when favorites change.
    /// Incremented whenever favorites are toggled to trigger SwiftUI re-render.
    private var favoritesUpdateTrigger = 0
    
    // MARK: - Private Dependencies
    
    private let countryService: CountryServiceProtocol
    private let llmService: LLMServiceProtocol
    private let favoritesManager: FavoritesManagerProtocol
    private let countryCode: String
    
    // MARK: - Initialization
    
    /// Initializes the ViewModel with required services.
    ///
    /// - Parameters:
    ///   - countryCode: The ISO 3166-1 alpha-2 country code (e.g., "US", "GB")
    ///   - countryService: The service to use for fetching country details.
    ///   - llmService: The service to use for generating fun facts.
    ///   - favoritesManager: The favorites manager to use.
    ///     Use `FavoritesManager()` for production or `MockFavoritesManager()` for testing.
    init(
        countryCode: String,
        countryService: CountryServiceProtocol,
        llmService: LLMServiceProtocol,
        favoritesManager: FavoritesManagerProtocol = FavoritesManager()
    ) {
        self.countryCode = countryCode
        self.countryService = countryService
        self.llmService = llmService
        self.favoritesManager = favoritesManager
    }
    
    // MARK: - Public Methods
    
    /// Loads the country details only (without generating fun fact).
    ///
    /// This method handles loading states and error management.
    /// Call this when the detail view appears.
    /// Fun fact must be generated separately via generateFunFact() or regenerateFunFact().
    func loadCountryDetails() async {
        // Reset error states
        errorMessage = nil
        funFactError = nil
        
        // Load country details only (fun fact is generated on demand)
        await loadCountryDetailsOnly()
    }
    
    /// Loads only the country details (without fun fact).
    ///
    /// This is used internally and can be called independently if needed.
    func loadCountryDetailsOnly() async {
        isLoadingCountry = true
        errorMessage = nil
        
        defer { isLoadingCountry = false }
        
        do {
            let countryDetail = try await countryService.fetchCountryDetails(code: countryCode)
            self.country = countryDetail
            errorMessage = nil
        } catch {
            errorMessage = userFriendlyErrorMessage(for: error)
            self.country = nil
        }
    }
    
    /// Generates a fun fact about the current country.
    ///
    /// This method handles loading states and error management.
    /// Can be called independently to regenerate the fun fact.
    func generateFunFact() async {
        // Ensure country details are loaded
        if country == nil {
            // If country is currently loading, wait for it
            if isLoadingCountry {
                while country == nil && isLoadingCountry {
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
                }
            }
            
            // If still no country, load it first
            if country == nil {
                await loadCountryDetailsOnly()
            }
        }
        
        // Convert CountryDetail to Country for LLM service
        guard let countryDetail = country else {
            funFactError = "Unable to generate fun fact. Country information not available."
            return
        }
        
        let countryForLLM = Country(
            id: countryDetail.id,
            name: countryDetail.name,
            code: countryDetail.code,
            emoji: countryDetail.emoji,
            continent: countryDetail.continent
        )
        
        await generateFunFactForCountry(countryForLLM)
    }
    
    /// Regenerates the fun fact.
    ///
    /// Convenience method to generate a new fun fact.
    func regenerateFunFact() async {
        funFact = nil
        funFactError = nil
        await generateFunFact()
    }
    
    // MARK: - Q&A Methods
    
    /// Asks a question about the current country.
    ///
    /// This method handles loading states and error management.
    /// The question and answer are added to the history.
    func askQuestion() async {
        guard !questionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        // Ensure country details are loaded
        if country == nil {
            if isLoadingCountry {
                while country == nil && isLoadingCountry {
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
                }
            }
            
            if country == nil {
                await loadCountryDetailsOnly()
            }
        }
        
        guard country != nil else {
            answerError = "Unable to answer question. Country information not available."
            return
        }
        
        let question = questionText.trimmingCharacters(in: .whitespacesAndNewlines)
        await generateAnswer(for: question)
    }
    
    /// Clears the current question and answer.
    func clearQuestion() {
        questionText = ""
        answer = nil
        answerError = nil
    }
    
    /// Clears the question history.
    func clearHistory() {
        questionHistory.removeAll()
    }
    
    // MARK: - Favorites Methods
    
    /// Toggles the favorite status of the current country.
    /// - Returns: `true` if the country is now favorited, `false` if it was removed
    func toggleFavorite() -> Bool {
        let result = favoritesManager.toggleFavorite(countryCode: countryCode)
        // Trigger UI update by incrementing the trigger
        favoritesUpdateTrigger += 1
        return result
    }
    
    /// Checks if the current country is favorited.
    /// - Returns: `true` if the country is favorited, `false` otherwise
    var isFavorite: Bool {
        // Access favoritesUpdateTrigger to ensure SwiftUI tracks this property
        _ = favoritesUpdateTrigger
        return favoritesManager.isFavorite(countryCode: countryCode)
    }
    
    // MARK: - Private Helpers
    
    /// Internal method to generate fun fact for a country.
    private func generateFunFactForCountry(_ country: Country) async {
        isLoadingFunFact = true
        funFactError = nil
        
        defer { isLoadingFunFact = false }
        
        do {
            let generatedFact = try await llmService.generateFunFact(about: country)
            self.funFact = generatedFact
            funFactError = nil
        } catch {
            funFactError = userFriendlyErrorMessage(for: error)
        }
    }
    
    /// Internal method to generate answer for a question.
    private func generateAnswer(for question: String) async {
        isLoadingAnswer = true
        answerError = nil
        answer = nil
        
        defer { isLoadingAnswer = false }
        
        do {
            let context = countryContext
            let generatedAnswer = try await llmService.answerQuestion(question, context: context)
            self.answer = generatedAnswer
            answerError = nil
            
            // Add to history
            let qa = QuestionAnswer(question: question, answer: generatedAnswer, timestamp: Date())
            questionHistory.append(qa)
            
            // Keep only last 10 questions
            if questionHistory.count > 10 {
                questionHistory.removeFirst()
            }
            
            // Clear question text after successful answer
            questionText = ""
        } catch {
            answerError = userFriendlyErrorMessage(for: error)
        }
    }
    
    /// Converts service errors into user-friendly error messages.
    private func userFriendlyErrorMessage(for error: Error) -> String {
        if let countryError = error as? CountryServiceError {
            return countryError.localizedDescription
        }
        
        if let llmError = error as? LLMServiceError {
            return llmError.localizedDescription
        }
        
        // Generic error fallback
        return "An error occurred. Please try again later."
    }
    
    // MARK: - Computed Properties
    
    /// Whether any loading operation is in progress.
    var isLoading: Bool {
        isLoadingCountry || isLoadingFunFact || isLoadingAnswer
    }
    
    /// Whether country details are available.
    var hasCountry: Bool {
        country != nil
    }
    
    /// Whether a fun fact is available.
    var hasFunFact: Bool {
        funFact != nil && !funFact!.isEmpty
    }
    
    /// Whether to show an error state.
    var shouldShowError: Bool {
        errorMessage != nil
    }
    
    /// Whether to show fun fact error state.
    var shouldShowFunFactError: Bool {
        funFactError != nil && !isLoadingFunFact
    }
    
    /// Formatted context string for the country (used for Q&A feature).
    var countryContext: String {
        guard let country = country else {
            return ""
        }
        
        var context = "Country: \(country.name) (\(country.emoji))\n"
        context += "Code: \(country.code)\n"
        
        if let continent = country.continent {
            context += "Continent: \(continent)\n"
        }
        
        if let capital = country.capital {
            context += "Capital: \(capital)\n"
        }
        
        if let currency = country.currency {
            context += "Currency: \(currency)\n"
        }
        
        if !country.languages.isEmpty {
            context += "Languages: \(country.languages.joined(separator: ", "))\n"
        }
        
        return context
    }
    
    /// Whether an answer is available.
    var hasAnswer: Bool {
        answer != nil && !answer!.isEmpty
    }
    
    /// Whether to show Q&A error state.
    var shouldShowAnswerError: Bool {
        answerError != nil && !isLoadingAnswer
    }
    
    /// Whether question history is available.
    var hasQuestionHistory: Bool {
        !questionHistory.isEmpty
    }
}

// MARK: - Question Answer Model

/// Represents a question and answer pair.
struct QuestionAnswer: Identifiable, Hashable {
    let id = UUID()
    let question: String
    let answer: String
    let timestamp: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: QuestionAnswer, rhs: QuestionAnswer) -> Bool {
        lhs.id == rhs.id
    }
}

