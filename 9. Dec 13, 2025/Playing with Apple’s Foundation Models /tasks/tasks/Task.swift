//
//  Task.swift
//  tasks
//
//  Created by Personal on 12/12/25.
//

import Foundation

/// Priority levels for tasks
enum TaskPriority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

/// Represents a single task item
/// Conforms to Identifiable for SwiftUI list display, Codable for persistence, and Hashable for List selection
struct Task: Identifiable, Codable, Hashable {
    /// Unique identifier for the task
    var id: UUID
    /// Task title/description
    var title: String
    /// Whether the task is completed
    var isCompleted: Bool
    /// Date when the task was created
    var createdDate: Date
    /// Optional due date for the task
    var dueDate: Date?
    /// Optional notes/description for the task
    var notes: String?
    /// Task priority level
    var priority: TaskPriority
    /// Optional category/tag for the task
    var category: String?
    
    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        createdDate: Date = Date(),
        dueDate: Date? = nil,
        notes: String? = nil,
        priority: TaskPriority = .medium,
        category: String? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdDate = createdDate
        self.dueDate = dueDate
        self.notes = notes
        self.priority = priority
        self.category = category
    }
    
    // MARK: - Codable Backward Compatibility
    
    /// Custom decoding to handle backward compatibility with tasks saved before priority/category were added
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        // Default to medium priority if not present (backward compatibility)
        priority = try container.decodeIfPresent(TaskPriority.self, forKey: .priority) ?? .medium
        category = try container.decodeIfPresent(String.self, forKey: .category)
    }
    
    /// Custom encoding to ensure all fields are properly encoded
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encodeIfPresent(dueDate, forKey: .dueDate)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encode(priority, forKey: .priority)
        try container.encodeIfPresent(category, forKey: .category)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, isCompleted, createdDate, dueDate, notes, priority, category
    }
}
