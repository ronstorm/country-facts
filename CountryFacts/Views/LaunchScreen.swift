//  LaunchScreen.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import SwiftUI

/// Launch screen displayed when the app starts.
/// Shows app branding and transitions to main content after a brief delay.
struct LaunchScreen: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.5
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // App icon or logo
                Text("🌍")
                    .font(.system(size: 80))
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                Text("CountryFacts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .opacity(opacity)
            }
        }
        .onAppear {
            // Animate in
            withAnimation(.easeOut(duration: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    LaunchScreen()
}

