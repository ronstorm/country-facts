//  SkeletonView.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import SwiftUI

/// A skeleton loading view that mimics the structure of content being loaded.
struct SkeletonView: View {
    let lines: Int
    let spacing: CGFloat
    
    init(lines: Int = 3, spacing: CGFloat = 8) {
        self.lines = lines
        self.spacing = spacing
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: spacing) {
                ForEach(0..<lines, id: \.self) { index in
                    skeletonLine(width: widthForLine(at: index, containerWidth: geometry.size.width))
                }
            }
            .frame(width: geometry.size.width)
        }
    }
    
    private func skeletonLine(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.gray.opacity(0.3))
            .frame(width: width, height: 16)
            .shimmer()
    }
    
    private func widthForLine(at index: Int, containerWidth: CGFloat) -> CGFloat {
        let percentages: [CGFloat] = [0.95, 0.8, 0.7]
        let percentage = percentages[min(index, percentages.count - 1)]
        return containerWidth * percentage
    }
}

/// Skeleton view for country row.
struct CountryRowSkeleton: View {
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 12) {
                // Flag placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 30)
                    .shimmer()
                
                // Text content
                VStack(alignment: .leading, spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 150, height: 16)
                        .shimmer()
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 100, height: 12)
                        .shimmer()
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
            .frame(width: geometry.size.width)
        }
        .frame(height: 50)
    }
}

/// Shimmer effect modifier for skeleton loading.
extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.white.opacity(0.3),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width)
                    .offset(x: phase)
                    .animation(
                        Animation.linear(duration: 1.5)
                            .repeatForever(autoreverses: false),
                        value: phase
                    )
                }
            )
            .onAppear {
                // Use a reasonable default width for shimmer animation
                phase = 400
            }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        SkeletonView(lines: 3)
            .padding()
        
        Divider()
        
        VStack(spacing: 8) {
            CountryRowSkeleton()
            CountryRowSkeleton()
            CountryRowSkeleton()
        }
        .padding()
    }
}

