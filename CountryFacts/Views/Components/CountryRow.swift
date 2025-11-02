//  CountryRow.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import SwiftUI

/// A row component displaying country information in a list.
struct CountryRow: View {
    let country: Country
    let isFavorite: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Flag emoji
            Text(country.emoji)
                .font(.system(size: 32))
                .frame(width: 40, height: 40, alignment: .center)
            
            // Country information
            VStack(alignment: .leading, spacing: 4) {
                Text(country.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                if let continent = country.continent {
                    Text(continent)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Favorite indicator (non-interactive, only shows if favorited)
            if isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                    .font(.system(size: 20))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview {
    List {
        CountryRow(
            country: Country(
                id: "US",
                name: "United States",
                code: "US",
                emoji: "🇺🇸",
                continent: "North America"
            ),
            isFavorite: true
        )
        CountryRow(
            country: Country(
                id: "GB",
                name: "United Kingdom",
                code: "GB",
                emoji: "🇬🇧",
                continent: "Europe"
            ),
            isFavorite: false
        )
    }
}

