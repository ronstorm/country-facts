//  View+CardStyle.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import SwiftUI

/// View extension providing reusable card styling.
extension View {
    /// Applies standard card styling used throughout the app.
    ///
    /// - Parameter padding: Padding value. Defaults to 16.
    /// - Returns: A view with card styling applied.
    func cardStyle(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
    }
    
    /// Applies standard button styling for primary actions.
    ///
    /// - Parameters:
    ///   - isEnabled: Whether the button is enabled
    ///   - isLoading: Whether the button should show loading state
    /// - Returns: A view with button styling applied.
    func primaryButtonStyle(isEnabled: Bool = true, isLoading: Bool = false) -> some View {
        self
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(isEnabled && !isLoading ? Color.accentColor : .secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isEnabled && !isLoading ? Color.accentColor.opacity(0.15) : Color.gray.opacity(0.1))
            .cornerRadius(8)
            .disabled(!isEnabled || isLoading)
    }
    
    /// Applies standard button styling for secondary actions.
    ///
    /// - Returns: A view with secondary button styling applied.
    func secondaryButtonStyle() -> some View {
        self
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(Color.accentColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.accentColor.opacity(0.1))
            .cornerRadius(8)
    }
}

