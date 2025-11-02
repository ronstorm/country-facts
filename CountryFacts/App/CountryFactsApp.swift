//  CountryFactsApp.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import SwiftUI

@main
struct CountryFactsApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

/// Root view that handles app initialization and launch screen.
struct RootView: View {
    @State private var showLaunchScreen = true
    
    var body: some View {
        Group {
            if showLaunchScreen {
                LaunchScreen()
            } else {
                CountryListView(
                    countryService: CountryService(),
                    llmService: GeminiService()
                )
            }
        }
        .task {
            // Show launch screen for a brief moment, then transition to main content
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            withAnimation {
                showLaunchScreen = false
            }
        }
    }
}
