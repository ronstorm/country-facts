//  ApolloExtensions.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import Foundation
import ApolloAPI

// MARK: - GetCountriesQuery.Data.Country Extension

extension CountryFactsSchema.GetCountriesQuery.Data.Country {
    /// Maps Apollo GraphQL country data to domain model.
    func toDomainModel() -> Country {
        Country(
            id: code,
            name: name,
            code: code,
            emoji: emoji,
            continent: continent.name
        )
    }
}

// MARK: - GetCountryDetailQuery.Data.Country Extension

extension CountryFactsSchema.GetCountryDetailQuery.Data.Country {
    /// Maps Apollo GraphQL country detail data to domain model.
    func toDomainModel() -> CountryDetail {
        CountryDetail(
            id: code,
            name: name,
            nativeName: native,
            code: code,
            emoji: emoji,
            continent: continent.name,
            capital: capital,
            currency: currency,
            languages: languages.map { $0.name }
        )
    }
}

