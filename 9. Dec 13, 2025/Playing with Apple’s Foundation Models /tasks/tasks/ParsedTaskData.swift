//
//  ParsedTaskData.swift
//  tasks
//
//  Created by Personal on 12/12/25.
//

import Foundation
import FoundationModels

/// Intermediate data structure for parsed task information before user confirmation
/// Used to hold AI-extracted task data that can be reviewed and edited before creating the actual Task
@Generable
struct ParsedTaskData {
    /// Extracted task title
    @Guide(description: "The main task title or description. This is required and should be clear and concise.")
    var title: String
    
    /// Extracted due date (if mentioned) as ISO8601 string
    @Guide(description: "The due date for the task if mentioned. Parse natural language dates like 'tomorrow', 'next Friday', 'in 3 days', or specific dates. Include time if specified (e.g., 'tomorrow at 2pm'). Format as ISO8601 date string (e.g., '2024-12-25T14:00:00Z'). Leave nil if no date is mentioned.")
    var dueDate: String?
    
    /// Extracted notes/description
    @Guide(description: "Additional notes, details, or context about the task. Leave nil if no additional information is provided.")
    var notes: String?
    
    /// Extracted priority level as raw string value
    @Guide(description: "The priority level: 'Low' for low priority tasks, 'Medium' for normal tasks (default), or 'High' for urgent/important tasks. Infer from keywords like 'urgent', 'important', 'low priority'. Use exactly 'Low', 'Medium', or 'High'.")
    var priority: String
    
    /// Extracted category/tag
    @Guide(description: "A category or tag for the task (e.g., 'Work', 'Personal', 'Shopping', 'Health'). Infer from context if possible. Leave nil if no category can be determined.")
    var category: String?
    
    /// Convert ParsedTaskData to a Task model
    func toTask() -> Task {
        // Parse the ISO8601 date string if present
        var parsedDueDate: Date? = nil
        if let dueDateString = dueDate {
            // Try multiple ISO8601 formats
            let formatters: [ISO8601DateFormatter] = [
                {
                    let f = ISO8601DateFormatter()
                    f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    return f
                }(),
                {
                    let f = ISO8601DateFormatter()
                    f.formatOptions = [.withInternetDateTime]
                    return f
                }(),
                {
                    let f = ISO8601DateFormatter()
                    f.formatOptions = [.withFullDate, .withTime]
                    return f
                }()
            ]
            
            for formatter in formatters {
                if let date = formatter.date(from: dueDateString) {
                    parsedDueDate = date
                    break
                }
            }
        }
        
        // Parse priority from string
        let taskPriority = TaskPriority(rawValue: priority) ?? .medium
        
        return Task(
            title: title,
            isCompleted: false,
            dueDate: parsedDueDate,
            notes: notes,
            priority: taskPriority,
            category: category
        )
    }
}

