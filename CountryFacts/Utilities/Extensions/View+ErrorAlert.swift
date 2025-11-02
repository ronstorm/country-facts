//  View+ErrorAlert.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import SwiftUI

/// View extension for displaying error alerts.
extension View {
    /// Presents an error alert when an error message is present.
    ///
    /// - Parameters:
    ///   - errorMessage: The error message to display, or nil to hide the alert.
    ///   - dismissAction: Optional action to perform when the alert is dismissed.
    func errorAlert(errorMessage: String?, dismissAction: (() -> Void)? = nil) -> some View {
        self.alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                dismissAction?()
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    /// Presents an error alert with a retry option.
    ///
    /// - Parameters:
    ///   - errorMessage: The error message to display, or nil to hide the alert.
    ///   - retryAction: Action to perform when retry is tapped.
    ///   - dismissAction: Optional action to perform when the alert is dismissed.
    func errorAlert(
        errorMessage: String?,
        retryAction: @escaping () -> Void,
        dismissAction: (() -> Void)? = nil
    ) -> some View {
        self.alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("Retry") {
                retryAction()
            }
            Button("Dismiss", role: .cancel) {
                dismissAction?()
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }
}

