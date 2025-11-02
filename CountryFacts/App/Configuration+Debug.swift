//  Configuration+Debug.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import Foundation

extension Configuration {
    /// Debug helper to print API key status (DEBUG builds only).
    static func debugAPIKeyStatus() {
        #if DEBUG
        print("🔍 API Key Debug Info:")
        print("   isConfigured: \(isConfigured)")
        print("   API key length: \(geminiAPIKey.count)")
        print("   API key preview: \(geminiAPIKey.isEmpty ? "EMPTY" : String(geminiAPIKey.prefix(10)) + "...")")
        
        // Check Info.plist
        if let infoPlistKey = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String {
            print("   ✅ Found in Info.plist: \(infoPlistKey.isEmpty ? "EMPTY" : String(infoPlistKey.prefix(10)) + "...")")
        } else {
            print("   ❌ Not found in Info.plist")
            print("   💡 To fix: Add GEMINI_API_KEY to Info.plist in Xcode")
        }
        
        // Check environment
        if let envKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] {
            print("   ✅ Found in environment: \(envKey.isEmpty ? "EMPTY" : String(envKey.prefix(10)) + "...")")
        } else {
            print("   ❌ Not found in environment")
        }
        #endif
    }
}

