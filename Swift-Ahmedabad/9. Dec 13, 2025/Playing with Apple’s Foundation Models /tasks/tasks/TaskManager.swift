//
//  TaskManager.swift
//  tasks
//
//  Created by Personal on 12/12/25.
//

import Foundation
import Combine

/// Filter options for task display
enum TaskFilter: String, CaseIterable {
    case all = "All"           // Show all tasks
    case active = "Active"     // Show only incomplete tasks
    case completed = "Completed" // Show only completed tasks
}

/// Manages task data, persistence, search, and filtering
/// Uses ObservableObject pattern to provide reactive updates to SwiftUI views
class TaskManager: ObservableObject {
    /// All tasks in the system
    @Published var tasks: [Task] = []
    /// Current search query text
    @Published var searchQuery: String = ""
    /// Current filter selection (All, Active, Completed)
    @Published var currentFilter: TaskFilter = .all
    
    /// UserDefaults key for persisting tasks
    private let tasksKey = "savedTasks"
    
    init() {
        loadTasks()
    }
    
    // MARK: - Search & Filter
    
    /// Get filtered and searched tasks
    var filteredTasks: [Task] {
        var filtered = tasks
        
        // Apply filter
        switch currentFilter {
        case .all:
            break // Show all tasks
        case .active:
            filtered = filtered.filter { !$0.isCompleted }
        case .completed:
            filtered = filtered.filter { $0.isCompleted }
        }
        
        // Apply search query
        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            filtered = filtered.filter { task in
                task.title.lowercased().contains(query)
            }
        }
        
        return filtered
    }
    
    /// Clear search query
    func clearSearch() {
        searchQuery = ""
    }
    
    // MARK: - CRUD Operations
    
    /// Add a new task
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }
    
    /// Delete a task by ID
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    /// Update an existing task
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    /// Toggle completion status of a task
    func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveTasks()
        }
    }
    
    // MARK: - Persistence
    
    /// Save tasks to UserDefaults using JSON encoding
    private func saveTasks() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let encoded = try encoder.encode(tasks)
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        } catch {
            print("Error saving tasks: \(error.localizedDescription)")
        }
    }
    
    /// Load tasks from UserDefaults
    private func loadTasks() {
        guard let data = UserDefaults.standard.data(forKey: tasksKey) else {
            // No saved tasks, initialize with empty array
            tasks = []
            return
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            tasks = try decoder.decode([Task].self, from: data)
        } catch {
            print("Error loading tasks: \(error.localizedDescription)")
            // On error, initialize with empty array
            tasks = []
        }
    }
}
