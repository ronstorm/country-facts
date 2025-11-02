//  CountryService.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import Foundation
import ApolloAPI

// MARK: - Apollo Import Note
// ApolloClient is in the Apollo module (separate from ApolloAPI)
// To fix the import error:
// 1. Open CountryFacts.xcodeproj in Xcode
// 2. Select the CountryFacts target
// 3. Go to "General" tab → "Frameworks, Libraries, and Embedded Content"
// 4. Click "+" and add "Apollo" from the package products
// 5. Or go to "Build Phases" → "Link Binary With Libraries" → Add "Apollo"
// Then add: import Apollo

#if canImport(Apollo)
import Apollo
#endif

/// Service for fetching country data from the Countries GraphQL API.
final class CountryService: CountryServiceProtocol {
    // MARK: - Properties
    
    private let apolloClient: ApolloClient
    
    // MARK: - Initialization
    
    /// Initializes the service with an Apollo client.
    ///
    /// - Parameter apolloClient: The Apollo client to use for GraphQL requests.
    ///   If not provided, creates a default client with the Countries API endpoint.
    init(apolloClient: ApolloClient? = nil) {
        if let client = apolloClient {
            self.apolloClient = client
        } else {
            let url = URL(string: Configuration.countriesGraphQLEndpoint)!
            self.apolloClient = ApolloClient(url: url)
        }
    }
    
    // MARK: - CountryServiceProtocol
    
    func fetchCountries() async throws -> [Country] {
        let query = CountryFactsSchema.GetCountriesQuery()
        
        return try await withCheckedThrowingContinuation { continuation in
            apolloClient.fetch(query: query) { result in
                switch result {
                case .success(let graphQLResult):
                    if let errors = graphQLResult.errors, !errors.isEmpty {
                        let error = errors.first!
                        continuation.resume(throwing: CountryServiceError.unknownError(
                            underlying: error
                        ))
                        return
                    }
                    
                    guard let data = graphQLResult.data else {
                        continuation.resume(throwing: CountryServiceError.noData)
                        return
                    }
                    
                    let countries = data.countries.map { $0.toDomainModel() }
                    continuation.resume(returning: countries)
                    
                case .failure(let error):
                    let serviceError: CountryServiceError
                    
                    // Map Apollo/URL errors to service errors
                    if let urlError = error as? URLError {
                        switch urlError.code {
                        case .timedOut:
                            serviceError = .timeout
                        case .notConnectedToInternet, .networkConnectionLost:
                            serviceError = .networkError(underlying: urlError)
                        default:
                            serviceError = .networkError(underlying: urlError)
                        }
                    } else {
                        serviceError = .networkError(underlying: error)
                    }
                    
                    continuation.resume(throwing: serviceError)
                }
            }
        }
    }
    
    func fetchCountryDetails(code: String) async throws -> CountryDetail {
        let query = CountryFactsSchema.GetCountryDetailQuery(code: code)
        
        return try await withCheckedThrowingContinuation { continuation in
            apolloClient.fetch(query: query) { result in
                switch result {
                case .success(let graphQLResult):
                    if let errors = graphQLResult.errors, !errors.isEmpty {
                        let error = errors.first!
                        continuation.resume(throwing: CountryServiceError.unknownError(
                            underlying: error
                        ))
                        return
                    }
                    
                    guard let data = graphQLResult.data else {
                        continuation.resume(throwing: CountryServiceError.noData)
                        return
                    }
                    
                    guard let countryData = data.country else {
                        continuation.resume(throwing: CountryServiceError.countryNotFound(
                            code: code
                        ))
                        return
                    }
                    
                    let countryDetail = countryData.toDomainModel()
                    continuation.resume(returning: countryDetail)
                    
                case .failure(let error):
                    let serviceError: CountryServiceError
                    
                    // Map Apollo/URL errors to service errors
                    if let urlError = error as? URLError {
                        switch urlError.code {
                        case .timedOut:
                            serviceError = .timeout
                        case .notConnectedToInternet, .networkConnectionLost:
                            serviceError = .networkError(underlying: urlError)
                        default:
                            serviceError = .networkError(underlying: urlError)
                        }
                    } else {
                        serviceError = .networkError(underlying: error)
                    }
                    
                    continuation.resume(throwing: serviceError)
                }
            }
        }
    }
}
