//  LoadingView.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import SwiftUI

/// A loading indicator view with optional message.
struct LoadingView: View {
    let message: String?
    let showSpinner: Bool
    
    init(message: String? = nil, showSpinner: Bool = true) {
        self.message = message
        self.showSpinner = showSpinner
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if showSpinner {
                ProgressView()
                    .scaleEffect(1.2)
            }
            
            if let message = message {
                Text(message)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    LoadingView(message: "Loading countries...")
}

