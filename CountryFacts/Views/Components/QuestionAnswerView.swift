//  QuestionAnswerView.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import SwiftUI

/// A view component for asking questions and displaying answers about a country.
struct QuestionAnswerView: View {
    @Binding var questionText: String
    let answer: String?
    let isLoading: Bool
    let errorMessage: String?
    let questionHistory: [QuestionAnswer]
    let onAsk: () -> Void
    let onClearHistory: () -> Void
    
    @State private var isHistoryExpanded = false
    
    var body: some View {
        cardView
    }
    
    private var cardView: some View {
        VStack(alignment: .leading, spacing: 16) {
            buildHeader()
            Divider()
            
            // Question input
            questionInputSection
            
            // Answer display
            if let answer = answer {
                answerView(answer)
            } else if isLoading {
                loadingView
            } else if let errorMessage = errorMessage {
                errorView(errorMessage)
            }
            
            // Question history
            if !questionHistory.isEmpty {
                Divider()
                historySection
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func buildHeader() -> some View {
        HStack {
            Image(systemName: "questionmark.circle.fill")
                .foregroundStyle(Color.accentColor)
                .font(.title3)
            
            Text("Ask a Question")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Spacer()
        }
    }
    
    private var questionInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Ask about this country...", text: $questionText, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(8)
                .lineLimit(3...6)
                .submitLabel(.send)
                .onSubmit {
                    if !questionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        onAsk()
                    }
                }
            
            Button(action: onAsk) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                    Text("Ask")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    questionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading
                        ? Color.gray
                        : Color.accentColor
                )
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .disabled(questionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
        }
    }
    
    private func answerView(_ answer: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "bubble.left.fill")
                    .foregroundStyle(Color.accentColor)
                    .font(.caption)
                
                Text("Answer")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
            }
            
            Text(answer)
                .font(.body)
                .foregroundStyle(.primary)
                .lineSpacing(4)
        }
        .padding(12)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var loadingView: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Generating answer...")
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
            
            Button(action: onAsk) {
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
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation {
                    isHistoryExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    
                    Text("Question History")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: isHistoryExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    
                    if !questionHistory.isEmpty {
                        Button(action: onClearHistory) {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .buttonStyle(.plain)
            
            if isHistoryExpanded {
                ForEach(questionHistory.reversed()) { qa in
                    historyItem(qa)
                }
            }
        }
    }
    
    private func historyItem(_ qa: QuestionAnswer) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Q:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Text(qa.question)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
            
            HStack(alignment: .top) {
                Text("A:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Text(qa.answer)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
                .padding(.top, 4)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        QuestionAnswerView(
            questionText: .constant("What is the capital?"),
            answer: "The capital of United States is Washington, D.C.",
            isLoading: false,
            errorMessage: nil,
            questionHistory: [
                QuestionAnswer(
                    question: "What is the capital?",
                    answer: "The capital of United States is Washington, D.C.",
                    timestamp: Date()
                )
            ],
            onAsk: {},
            onClearHistory: {}
        )
        
        QuestionAnswerView(
            questionText: .constant(""),
            answer: nil,
            isLoading: true,
            errorMessage: nil,
            questionHistory: [],
            onAsk: {},
            onClearHistory: {}
        )
    }
    .padding()
}

