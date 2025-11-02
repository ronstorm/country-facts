//  CountryDetailViewModelTests.swift
//  CountryFactsTests
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import XCTest
@testable import CountryFacts

/// Unit tests for CountryDetailViewModel.
@MainActor
final class CountryDetailViewModelTests: XCTestCase {
    var sut: CountryDetailViewModel!
    var mockCountryService: MockCountryService!
    var mockLLMService: MockLLMService!
    let testCountryCode = "US"
    
    override func setUp() {
        super.setUp()
        mockCountryService = MockCountryService()
        mockLLMService = MockLLMService()
        sut = CountryDetailViewModel(
            countryCode: testCountryCode,
            countryService: mockCountryService,
            llmService: mockLLMService
        )
    }
    
    override func tearDown() {
        sut = nil
        mockCountryService = nil
        mockLLMService = nil
        super.tearDown()
    }
    
    // MARK: - Load Country Details Tests
    
    func testLoadCountryDetails_Success_UpdatesCountry() async {
        // Given
        let testCountryDetail = TestHelpers.makeTestCountryDetail()
        mockCountryService.mockCountryDetails[testCountryCode] = testCountryDetail
        
        // When
        await sut.loadCountryDetails()
        
        // Then
        XCTAssertFalse(sut.isLoadingCountry)
        XCTAssertNil(sut.errorMessage)
        XCTAssertNotNil(sut.country)
        XCTAssertEqual(sut.country?.code, testCountryCode)
    }
    
    func testLoadCountryDetails_NetworkError_SetsErrorMessage() async {
        // Given
        mockCountryService.shouldThrowErrorOnFetchDetails = true
        mockCountryService.mockError = .networkError(underlying: NSError(domain: "Test", code: 1))
        
        // When
        await sut.loadCountryDetails()
        
        // Then
        XCTAssertFalse(sut.isLoadingCountry)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertNil(sut.country)
    }
    
    func testLoadCountryDetails_CountryNotFound_SetsErrorMessage() async {
        // Given
        mockCountryService.mockCountryDetails.removeValue(forKey: testCountryCode)
        
        // When
        await sut.loadCountryDetails()
        
        // Then
        XCTAssertFalse(sut.isLoadingCountry)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertNil(sut.country)
    }
    
    func testLoadCountryDetails_DuringLoad_IsLoadingCountryIsTrue() async {
        // Given
        mockCountryService.delay = 0.2
        let testCountryDetail = TestHelpers.makeTestCountryDetail()
        mockCountryService.mockCountryDetails[testCountryCode] = testCountryDetail
        
        // When
        let loadTask = Task {
            await sut.loadCountryDetails()
        }
        
        // Then - check loading state after a small delay to ensure the task has started
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        XCTAssertTrue(sut.isLoadingCountry)
        
        // Wait for completion
        await loadTask.value
        XCTAssertFalse(sut.isLoadingCountry)
    }
    
    func testLoadCountryDetails_ClearsFunFactError() async {
        // Given
        sut.funFactError = "Previous error"
        let testCountryDetail = TestHelpers.makeTestCountryDetail()
        mockCountryService.mockCountryDetails[testCountryCode] = testCountryDetail
        
        // When
        await sut.loadCountryDetails()
        
        // Then
        XCTAssertNil(sut.funFactError)
    }
    
    // MARK: - Generate Fun Fact Tests
    
    func testGenerateFunFact_Success_UpdatesFunFact() async {
        // Given
        let testCountryDetail = TestHelpers.makeTestCountryDetail()
        mockCountryService.mockCountryDetails[testCountryCode] = testCountryDetail
        await sut.loadCountryDetails()
        
        let expectedFunFact = "The United States has amazing facts!"
        mockLLMService.mockFunFacts[testCountryCode] = expectedFunFact
        
        // When
        await sut.generateFunFact()
        
        // Then
        XCTAssertFalse(sut.isLoadingFunFact)
        XCTAssertNil(sut.funFactError)
        XCTAssertEqual(sut.funFact, expectedFunFact)
    }
    
    func testGenerateFunFact_WhenCountryNotLoaded_LoadsCountryFirst() async {
        // Given
        let testCountryDetail = TestHelpers.makeTestCountryDetail()
        mockCountryService.mockCountryDetails[testCountryCode] = testCountryDetail
        let expectedFunFact = "The United States has amazing facts!"
        mockLLMService.mockFunFacts[testCountryCode] = expectedFunFact
        
        // When
        await sut.generateFunFact()
        
        // Then
        XCTAssertNotNil(sut.country)
        XCTAssertEqual(sut.funFact, expectedFunFact)
    }
    
    func testGenerateFunFact_LLMError_SetsFunFactError() async {
        // Given
        let testCountryDetail = TestHelpers.makeTestCountryDetail()
        mockCountryService.mockCountryDetails[testCountryCode] = testCountryDetail
        await sut.loadCountryDetails()
        
        mockLLMService.shouldThrowErrorOnFunFact = true
        mockLLMService.mockError = .invalidAPIKey
        
        // When
        await sut.generateFunFact()
        
        // Then
        XCTAssertFalse(sut.isLoadingFunFact)
        XCTAssertNotNil(sut.funFactError)
        XCTAssertNil(sut.funFact)
    }
    
    func testGenerateFunFact_DuringGeneration_IsLoadingFunFactIsTrue() async {
        // Given
        let testCountryDetail = TestHelpers.makeTestCountryDetail()
        mockCountryService.mockCountryDetails[testCountryCode] = testCountryDetail
        await sut.loadCountryDetails()
        
        mockLLMService.delay = 0.2
        mockLLMService.mockFunFacts[testCountryCode] = "Test fact"
        
        // When
        let generateTask = Task {
            await sut.generateFunFact()
        }
        
        // Then - check loading state after a small delay to ensure the task has started
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        XCTAssertTrue(sut.isLoadingFunFact)
        
        // Wait for completion
        await generateTask.value
        XCTAssertFalse(sut.isLoadingFunFact)
    }
    
    func testGenerateFunFact_WithoutCountry_SetsError() async {
        // Given
        mockCountryService.mockCountryDetails.removeValue(forKey: testCountryCode)
        
        // When
        await sut.generateFunFact()
        
        // Then
        XCTAssertNotNil(sut.funFactError)
        XCTAssertEqual(sut.funFactError, "Unable to generate fun fact. Country information not available.")
    }
    
    // MARK: - Regenerate Fun Fact Tests
    
    func testRegenerateFunFact_ClearsPreviousFunFact() async {
        // Given
        let testCountryDetail = TestHelpers.makeTestCountryDetail()
        mockCountryService.mockCountryDetails[testCountryCode] = testCountryDetail
        await sut.loadCountryDetails()
        
        sut.funFact = "Old fact"
        sut.funFactError = "Previous error"
        mockLLMService.mockFunFacts[testCountryCode] = "New fact"
        
        // When
        await sut.regenerateFunFact()
        
        // Then
        XCTAssertNil(sut.funFactError)
        XCTAssertEqual(sut.funFact, "New fact")
    }
    
    // MARK: - Computed Properties Tests
    
    func testIsLoading_WhenCountryLoading_ReturnsTrue() async {
        // Given
        mockCountryService.delay = 0.2
        let task = Task {
            await sut.loadCountryDetails()
        }
        
        // Then - check loading state after a small delay to ensure the task has started
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        XCTAssertTrue(sut.isLoading)
        
        await task.value
    }
    
    func testIsLoading_WhenFunFactLoading_ReturnsTrue() async {
        // Given
        let testCountryDetail = TestHelpers.makeTestCountryDetail()
        mockCountryService.mockCountryDetails[testCountryCode] = testCountryDetail
        await sut.loadCountryDetails()
        
        mockLLMService.delay = 0.2
        let task = Task {
            await sut.generateFunFact()
        }
        
        // Then - check loading state after a small delay to ensure the task has started
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        XCTAssertTrue(sut.isLoading)
        
        await task.value
    }
    
    func testIsLoading_WhenNotLoading_ReturnsFalse() async {
        // Then
        XCTAssertFalse(sut.isLoading)
    }
    
    func testHasCountry_WithCountry_ReturnsTrue() async {
        // Given
        let testCountryDetail = TestHelpers.makeTestCountryDetail()
        mockCountryService.mockCountryDetails[testCountryCode] = testCountryDetail
        await sut.loadCountryDetails()
        
        // Then
        XCTAssertTrue(sut.hasCountry)
    }
    
    func testHasCountry_WithoutCountry_ReturnsFalse() {
        // Then
        XCTAssertFalse(sut.hasCountry)
    }
    
    func testHasFunFact_WithFunFact_ReturnsTrue() async {
        // Given
        let testCountryDetail = TestHelpers.makeTestCountryDetail()
        mockCountryService.mockCountryDetails[testCountryCode] = testCountryDetail
        await sut.loadCountryDetails()
        
        sut.funFact = "Test fact"
        
        // Then
        XCTAssertTrue(sut.hasFunFact)
    }
    
    func testHasFunFact_EmptyFunFact_ReturnsFalse() {
        sut.funFact = ""
        
        // Then
        XCTAssertFalse(sut.hasFunFact)
    }
    
    func testHasFunFact_WithoutFunFact_ReturnsFalse() {
        // Then
        XCTAssertFalse(sut.hasFunFact)
    }
    
    func testShouldShowError_WithErrorMessage_ReturnsTrue() async {
        // Given
        mockCountryService.shouldThrowErrorOnFetchDetails = true
        mockCountryService.mockError = .networkError(underlying: NSError(domain: "Test", code: 1))
        await sut.loadCountryDetails()
        
        // Then
        XCTAssertTrue(sut.shouldShowError)
    }
    
    func testShouldShowError_WithoutError_ReturnsFalse() async {
        // Given
        let testCountryDetail = TestHelpers.makeTestCountryDetail()
        mockCountryService.mockCountryDetails[testCountryCode] = testCountryDetail
        await sut.loadCountryDetails()
        
        // Then
        XCTAssertFalse(sut.shouldShowError)
    }
    
    func testShouldShowFunFactError_WithError_ReturnsTrue() async {
        // Given
        let testCountryDetail = TestHelpers.makeTestCountryDetail()
        mockCountryService.mockCountryDetails[testCountryCode] = testCountryDetail
        await sut.loadCountryDetails()
        
        mockLLMService.shouldThrowErrorOnFunFact = true
        mockLLMService.mockError = .invalidAPIKey
        await sut.generateFunFact()
        
        // Then
        XCTAssertTrue(sut.shouldShowFunFactError)
    }
    
    func testShouldShowFunFactError_DuringLoading_ReturnsFalse() async {
        // Given
        let testCountryDetail = TestHelpers.makeTestCountryDetail()
        mockCountryService.mockCountryDetails[testCountryCode] = testCountryDetail
        await sut.loadCountryDetails()
        
        mockLLMService.delay = 0.1
        let task = Task {
            await sut.generateFunFact()
        }
        
        // Then
        XCTAssertFalse(sut.shouldShowFunFactError)
        
        await task.value
    }
    
    func testCountryContext_WithCompleteCountry_ReturnsFormattedContext() async {
        // Given
        let testCountryDetail = TestHelpers.makeTestCountryDetail(
            capital: "Washington, D.C.",
            currency: "USD",
            languages: ["English", "Spanish"]
        )
        mockCountryService.mockCountryDetails[testCountryCode] = testCountryDetail
        await sut.loadCountryDetails()
        
        // When
        let context = sut.countryContext
        
        // Then
        XCTAssertTrue(context.contains("United States"))
        XCTAssertTrue(context.contains("🇺🇸"))
        XCTAssertTrue(context.contains("US"))
        XCTAssertTrue(context.contains("Washington, D.C."))
        XCTAssertTrue(context.contains("USD"))
        XCTAssertTrue(context.contains("English"))
        XCTAssertTrue(context.contains("Spanish"))
    }
    
    func testCountryContext_WithoutCountry_ReturnsEmptyString() {
        // Then
        XCTAssertTrue(sut.countryContext.isEmpty)
    }
    
    func testCountryContext_WithMinimalCountry_ReturnsBasicContext() async {
        // Given
        let testCountryDetail = CountryDetail(
            id: "US",
            name: "United States",
            nativeName: nil,
            code: "US",
            emoji: "🇺🇸",
            continent: nil,
            capital: nil,
            currency: nil,
            languages: []
        )
        mockCountryService.mockCountryDetails[testCountryCode] = testCountryDetail
        await sut.loadCountryDetails()
        
        // When
        let context = sut.countryContext
        
        // Then
        XCTAssertTrue(context.contains("United States"))
        XCTAssertTrue(context.contains("🇺🇸"))
        XCTAssertTrue(context.contains("US"))
    }
}

