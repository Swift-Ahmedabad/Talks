//
//  SmartTaskService.swift
//  tasks
//
//  Created by Personal on 12/12/25.
//

import Combine
import Foundation
import FoundationModels

/// Errors that can occur in the smart task service
enum SmartTaskServiceError: LocalizedError {
    case modelNotAvailable
    case parsingFailed(String)
    case invalidInput
    
    var errorDescription: String? {
        switch self {
        case .modelNotAvailable:
            return "The AI model is still initializing. Please wait a moment and try again."
        case .parsingFailed(let reason):
            return "Failed to parse task: \(reason)"
        case .invalidInput:
            return "Input is empty or invalid"
        }
    }
}

/// Service for parsing natural language task descriptions using Apple Foundation Models
@MainActor
class SmartTaskService: ObservableObject {
    /// Whether the AI model is available and loaded
    @Published var isModelAvailable: Bool = false
    /// Whether the service is currently processing a request
    @Published var isProcessing: Bool = false
    
    private var session: LanguageModelSession?
    
    init() {
        // Use concurrency Task (not the custom Task struct)
        _Concurrency.Task {
            await loadModel()
        }
    }
    
    /// Load the Foundation Models framework
    private func loadModel() async {
        // Create a LanguageModelSession with instructions
        let instructions = createModelInstructions()
        let session = LanguageModelSession(instructions: instructions)
        self.session = session
        self.isModelAvailable = true
    }
    
    /// Create instructions for the language model to guide task extraction
    private func createModelInstructions() -> String {
        return """
        You are a task extraction assistant. Extract task information from natural language input.
        
        Your job is to parse natural language task descriptions and extract:
        - The main task title (required)
        - Due date if mentioned (parse natural language dates like "tomorrow", "next Friday", "in 3 days")
        - Additional notes or context
        - Priority level (low, medium, or high) based on keywords like "urgent", "important", "low priority"
        - Category/tag (Work, Personal, Shopping, Health, etc.) inferred from context
        
        Be accurate and only extract information that is clearly stated or strongly implied in the input.
        """
    }
    
    /// Parse natural language input into structured task data
    /// - Parameter input: Natural language description of the task
    /// - Returns: ParsedTaskData containing extracted task information
    /// - Throws: SmartTaskServiceError if parsing fails
    func parseTaskFromNaturalLanguage(_ input: String) async throws -> ParsedTaskData {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw SmartTaskServiceError.invalidInput
        }
        
        guard isModelAvailable else {
            throw SmartTaskServiceError.modelNotAvailable
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            return try await generateTaskWithGuidedGeneration(input)
        } catch let error as SmartTaskServiceError {
            throw error
        } catch {
            throw SmartTaskServiceError.parsingFailed(error.localizedDescription)
        }
    }
    
    /// Generate task extraction using Foundation Models with guided generation
    /// - Parameter input: Natural language task description
    /// - Returns: ParsedTaskData with extracted task information
    private func generateTaskWithGuidedGeneration(_ input: String) async throws -> ParsedTaskData {
        guard let session = self.session else {
            throw SmartTaskServiceError.modelNotAvailable
        }
        
        // Create the prompt for task extraction
        let prompt = createExtractionPrompt(from: input)
        
        // Use guided generation to directly create ParsedTaskData
        let response = try await session.respond(to: prompt, generating: ParsedTaskData.self)
        
        // Extract the content from the response
        let parsedData = response.content
        
        // Validate that we got a valid result
        guard !parsedData.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw SmartTaskServiceError.parsingFailed("Generated task title is empty")
        }
        
        return parsedData
    }
    
    /// Create a structured prompt for task extraction
    private func createExtractionPrompt(from input: String) -> String {
        return """
        Extract task information from: "\(input)"
        """
    }
}

