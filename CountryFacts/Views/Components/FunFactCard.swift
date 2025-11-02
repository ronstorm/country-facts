//  FunFactCard.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import SwiftUI

/// A card component displaying a fun fact about a country.
struct FunFactCard: View {
    let funFact: String?
    let isLoading: Bool
    let errorMessage: String?
    let onRetry: () -> Void
    let onGenerate: () -> Void
    
    var body: some View {
        cardView
    }
    
    private var cardView: some View {
        VStack(alignment: .leading, spacing: 12) {
            buildHeader()
            Divider()
            buildContent()
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func buildHeader() -> some View {
        HStack {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.yellow)
                .font(.title3)
            
            Text("Fun Fact")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func buildContent() -> some View {
        if isLoading {
            loadingView
        } else if let errorMessage = errorMessage {
            errorView(errorMessage)
        } else if let funFact = funFact {
            funFactView(funFact)
        } else {
            emptyStateView
        }
    }
    
    private var loadingView: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Generating fun fact...")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            Button(action: onRetry) {
                Text("Try Again")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.accentColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.accentColor.opacity(0.15))
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
    }
    
    private func funFactView(_ fact: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(fact)
                .font(.body)
                .foregroundStyle(.primary)
                .lineSpacing(4)
            
            generateNewButton
        }
    }
    
    private var generateNewButton: some View {
        Button(action: onGenerate) {
            HStack {
                Image(systemName: "arrow.clockwise")
                Text("Generate New")
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
            .foregroundStyle(Color.accentColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.accentColor.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
    
    private var emptyStateView: some View {
        Button(action: onGenerate) {
            HStack {
                Image(systemName: "sparkles")
                Text("Generate Fun Fact")
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
            .foregroundStyle(Color.accentColor)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.accentColor.opacity(0.15))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        FunFactCard(
            funFact: "The United States has more than 10,000 airports, more than any other country in the world!",
            isLoading: false,
            errorMessage: nil,
            onRetry: {},
            onGenerate: {}
        )
        
        FunFactCard(
            funFact: nil,
            isLoading: true,
            errorMessage: nil,
            onRetry: {},
            onGenerate: {}
        )
        
        FunFactCard(
            funFact: nil,
            isLoading: false,
            errorMessage: "Unable to generate fun fact",
            onRetry: {},
            onGenerate: {}
        )
        
        FunFactCard(
            funFact: nil,
            isLoading: false,
            errorMessage: nil,
            onRetry: {},
            onGenerate: {}
        )
    }
    .padding()
}
