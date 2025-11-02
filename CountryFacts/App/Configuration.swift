//  Configuration.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import Foundation

/// Manages application configuration including API keys and endpoints.
enum Configuration {
    // MARK: - API Endpoints
    
    /// Countries GraphQL API endpoint.
    static let countriesGraphQLEndpoint = "https://countries.trevorblades.com/"
    
    /// Gemini API endpoint.
    static let geminiAPIEndpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent"
    
    // MARK: - API Keys
    
    /// Gemini API key loaded from environment or configuration.
    /// 
    /// Priority order:
    /// 1. Info.plist key "GEMINI_API_KEY" (set from Config.xcconfig)
    /// 2. Environment variable "GEMINI_API_KEY"
    /// 3. Empty string (will cause errors if used)
    /// 
    /// To set up:
    /// Option 1 (Recommended): Add directly to Info.plist
    ///   - In Xcode: Select project → Target → Info tab
    ///   - Add key: "GEMINI_API_KEY" with your API key as value
    /// 
    /// Option 2: Use Config.xcconfig (requires linking in Build Settings)
    ///   - Config.xcconfig file exists in project root
    ///   - Link it in Build Settings → Configuration File
    ///   - Set INFOPLIST_KEY_GEMINI_API_KEY = $(GEMINI_API_KEY)
    static var geminiAPIKey: String {
        // Try to get from Info.plist first (can be set from Config.xcconfig)
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String,
           !apiKey.isEmpty {
            return apiKey
        }
        
        // Try to get from environment variable (for runtime/testing)
        if let apiKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"],
           !apiKey.isEmpty {
            return apiKey
        }
        
        // Fallback: return empty string (will cause errors, but allows graceful handling)
        return ""
    }
    
    // MARK: - Validation
    
    /// Checks if API keys are properly configured.
    static var isConfigured: Bool {
        !geminiAPIKey.isEmpty
    }
}

