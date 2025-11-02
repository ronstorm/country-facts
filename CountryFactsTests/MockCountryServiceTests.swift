//  MockCountryServiceTests.swift
//  CountryFactsTests
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import XCTest
@testable import CountryFacts

/// Unit tests for MockCountryService.
///
/// These tests verify that MockCountryService works correctly and can be used
/// for testing ViewModels and other components that depend on CountryServiceProtocol.
@MainActor
final class MockCountryServiceTests: XCTestCase {
    var sut: MockCountryService!
    
    override func setUp() {
        super.setUp()
        sut = MockCountryService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Fetch Countries Tests
    
    func testFetchCountries_Success_ReturnsMockData() async throws {
        // Given
        // MockCountryService has default mock data set up
        
        // When
        let countries = try await sut.fetchCountries()
        
        // Then
        XCTAssertFalse(countries.isEmpty, "Should return mock countries")
        XCTAssertEqual(countries.count, 3, "Should return 3 default mock countries")
        
        // Extract codes to avoid actor isolation warnings
        let countryCodes = countries.map { $0.code }
        XCTAssertTrue(countryCodes.contains("US"), "Should contain United States")
        XCTAssertTrue(countryCodes.contains("GB"), "Should contain United Kingdom")
        XCTAssertTrue(countryCodes.contains("JP"), "Should contain Japan")
    }
    
    func testFetchCountries_WithCustomMockData_ReturnsCustomData() async throws {
        // Given
        let customCountries = [
            Country(id: "CA", name: "Canada", code: "CA", emoji: "🇨🇦", continent: "North America"),
            Country(id: "MX", name: "Mexico", code: "MX", emoji: "🇲🇽", continent: "North America")
        ]
        sut.mockCountries = customCountries
        
        // When
        let countries = try await sut.fetchCountries()
        
        // Then
        XCTAssertEqual(countries.count, 2)
        let firstCode = countries.first?.code
        let lastCode = countries.last?.code
        XCTAssertEqual(firstCode, "CA")
        XCTAssertEqual(lastCode, "MX")
    }
    
    func testFetchCountries_WithErrorSimulation_ThrowsError() async {
        // Given
        sut.shouldThrowErrorOnFetchCountries = true
        sut.mockError = .networkError(underlying: NSError(domain: "Test", code: 1))
        
        // When/Then
        do {
            _ = try await sut.fetchCountries()
            XCTFail("Should throw error")
        } catch let error as CountryServiceError {
            if case .networkError = error {
                // Expected error type
            } else {
                XCTFail("Expected networkError, got \(error)")
            }
        } catch {
            XCTFail("Expected CountryServiceError, got \(error)")
        }
    }
    
    func testFetchCountries_WithDelay_RespectsDelay() async throws {
        // Given
        sut.delay = 0.1
        let startTime = Date()
        
        // When
        _ = try await sut.fetchCountries()
        let elapsedTime = Date().timeIntervalSince(startTime)
        
        // Then
        XCTAssertGreaterThanOrEqual(elapsedTime, 0.05, "Should respect delay (allowing 0.05s tolerance)")
    }
    
    // MARK: - Fetch Country Details Tests
    
    func testFetchCountryDetails_Success_ReturnsMockData() async throws {
        // Given
        let countryCode = "US"
        
        // When
        let countryDetail = try await sut.fetchCountryDetails(code: countryCode)
        
        // Then
        let code = countryDetail.code
        let name = countryDetail.name
        let emoji = countryDetail.emoji
        let continent = countryDetail.continent
        let capital = countryDetail.capital
        let currency = countryDetail.currency
        let languages = countryDetail.languages
        
        XCTAssertEqual(code, countryCode)
        XCTAssertEqual(name, "United States")
        XCTAssertEqual(emoji, "🇺🇸")
        XCTAssertEqual(continent, "North America")
        XCTAssertEqual(capital, "Washington, D.C.")
        XCTAssertEqual(currency, "USD")
        XCTAssertFalse(languages.isEmpty)
    }
    
    func testFetchCountryDetails_WithValidCode_ReturnsCompleteData() async throws {
        // Given
        let countryCode = "JP"
        
        // When
        let countryDetail = try await sut.fetchCountryDetails(code: countryCode)
        
        // Then
        let code = countryDetail.code
        let name = countryDetail.name
        let nativeName = countryDetail.nativeName
        let capital = countryDetail.capital
        let currency = countryDetail.currency
        let firstLanguage = countryDetail.languages.first
        
        XCTAssertEqual(code, countryCode)
        XCTAssertEqual(name, "Japan")
        XCTAssertEqual(nativeName, "日本")
        XCTAssertEqual(capital, "Tokyo")
        XCTAssertEqual(currency, "JPY")
        XCTAssertEqual(firstLanguage, "Japanese")
    }
    
    func testFetchCountryDetails_WithInvalidCode_ThrowsNotFoundError() async {
        // Given
        let invalidCode = "INVALID"
        
        // When/Then
        do {
            _ = try await sut.fetchCountryDetails(code: invalidCode)
            XCTFail("Should throw CountryServiceError.countryNotFound")
        } catch let error as CountryServiceError {
            if case .countryNotFound(let code) = error {
                XCTAssertEqual(code, invalidCode)
            } else {
                XCTFail("Expected countryNotFound error, got \(error)")
            }
        } catch {
            XCTFail("Expected CountryServiceError, got \(error)")
        }
    }
    
    func testFetchCountryDetails_WithErrorSimulation_ThrowsError() async {
        // Given
        sut.shouldThrowErrorOnFetchDetails = true
        sut.mockError = .networkError(underlying: NSError(domain: "Test", code: 1))
        
        // When/Then
        do {
            _ = try await sut.fetchCountryDetails(code: "US")
            XCTFail("Should throw error")
        } catch let error as CountryServiceError {
            if case .networkError = error {
                // Expected error type
            } else {
                XCTFail("Expected networkError, got \(error)")
            }
        } catch {
            XCTFail("Expected CountryServiceError, got \(error)")
        }
    }
    
    func testFetchCountryDetails_WithCustomMockData_ReturnsCustomData() async throws {
        // Given
        let customDetail = CountryDetail(
            id: "FR",
            name: "France",
            nativeName: "France",
            code: "FR",
            emoji: "🇫🇷",
            continent: "Europe",
            capital: "Paris",
            currency: "EUR",
            languages: ["French"]
        )
        sut.mockCountryDetails["FR"] = customDetail
        
        // When
        let countryDetail = try await sut.fetchCountryDetails(code: "FR")
        
        // Then
        let code = countryDetail.code
        let name = countryDetail.name
        let capital = countryDetail.capital
        
        XCTAssertEqual(code, "FR")
        XCTAssertEqual(name, "France")
        XCTAssertEqual(capital, "Paris")
    }
}

