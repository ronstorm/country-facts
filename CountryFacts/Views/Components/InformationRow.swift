//  InformationRow.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import SwiftUI

/// A row component displaying a label and value pair for country information.
struct InformationRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview {
    VStack(alignment: .leading, spacing: 0) {
        InformationRow(label: "Capital", value: "Washington, D.C.")
        InformationRow(label: "Currency", value: "USD")
        InformationRow(label: "Languages", value: "English")
    }
    .padding()
}

