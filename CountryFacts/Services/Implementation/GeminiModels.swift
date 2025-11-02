//  GeminiModels.swift
//  CountryFacts
//
//  Created by Amit Sen on November 1, 2025.
//  © 2025 Coding With Amit. All rights reserved.

import Foundation

// MARK: - Request Models

/// Request model for Gemini API generateContent endpoint.
struct GeminiGenerateContentRequest: Codable {
    let contents: [GeminiContent]
    let generationConfig: GeminiGenerationConfig?
    
    struct GeminiContent: Codable {
        let parts: [GeminiPart]
    }
    
    struct GeminiPart: Codable {
        let text: String
    }
    
    struct GeminiGenerationConfig: Codable {
        let temperature: Double?
        let topK: Int?
        let topP: Double?
        let maxOutputTokens: Int?
        
        enum CodingKeys: String, CodingKey {
            case temperature
            case topK
            case topP
            case maxOutputTokens
        }
    }
    
    init(contents: [GeminiContent], generationConfig: GeminiGenerationConfig? = nil) {
        self.contents = contents
        self.generationConfig = generationConfig
    }
    
    /// Creates a request for fun fact generation.
    static func funFactRequest(for country: Country) -> GeminiGenerateContentRequest {
        let prompt = """
        Generate a fun, interesting, and engaging fact about \(country.name) (\(country.emoji)). 
        Keep it concise (1-2 sentences), educational, and entertaining. 
        Focus on something unique or surprising about the country.
        """
        
        let content = GeminiContent(parts: [GeminiPart(text: prompt)])
        let config = GeminiGenerationConfig(
            temperature: 0.8,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 150
        )
        
        return GeminiGenerateContentRequest(contents: [content], generationConfig: config)
    }
    
    /// Creates a request for question answering.
    static func questionRequest(question: String, context: String) -> GeminiGenerateContentRequest {
        let prompt = """
        You are a helpful assistant answering questions about countries. Use the following context about a specific country to answer the user's question accurately and concisely.
        
        Country Context:
        \(context)
        
        User Question: \(question)
        
        Instructions:
        - Provide a clear, concise, and accurate answer based on the context provided
        - If the question cannot be answered from the context, politely say so
        - Keep answers informative but brief (2-3 sentences maximum)
        - Use a friendly, conversational tone
        """
        
        let content = GeminiContent(parts: [GeminiPart(text: prompt)])
        let config = GeminiGenerationConfig(
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 300
        )
        
        return GeminiGenerateContentRequest(contents: [content], generationConfig: config)
    }
}

// MARK: - Response Models

/// Response model for Gemini API generateContent endpoint.
struct GeminiGenerateContentResponse: Codable {
    let candidates: [GeminiCandidate]?
    let promptFeedback: GeminiPromptFeedback?
    
    struct GeminiCandidate: Codable {
        let content: GeminiContent
        let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case content
            case finishReason
        }
    }
    
    struct GeminiContent: Codable {
        let parts: [GeminiPart]
    }
    
    struct GeminiPart: Codable {
        let text: String?
    }
    
    struct GeminiPromptFeedback: Codable {
        let blockReason: String?
        
        enum CodingKeys: String, CodingKey {
            case blockReason
        }
    }
    
    /// Extracts the generated text from the response.
    var generatedText: String? {
        guard let candidate = candidates?.first,
              let part = candidate.content.parts.first,
              let text = part.text else {
            return nil
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Error Response Model

/// Error response model for Gemini API.
struct GeminiErrorResponse: Codable {
    let error: GeminiError
    
    struct GeminiError: Codable {
        let code: Int?
        let message: String?
        let status: String?
    }
}

