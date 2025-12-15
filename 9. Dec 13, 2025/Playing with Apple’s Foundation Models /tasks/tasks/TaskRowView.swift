//
//  TaskRowView.swift
//  tasks
//
//  Created by Personal on 12/12/25.
//

import SwiftUI

/// Displays a single task row in the task list
/// Shows task title, completion status, and optional due date
struct TaskRowView: View {
    /// The task to display
    let task: Task
    /// Callback when completion status is toggled
    let onToggleCompletion: () -> Void
    /// Optional callback when task is double-clicked for editing
    let onEdit: (() -> Void)?
    
    init(task: Task, onToggleCompletion: @escaping () -> Void, onEdit: (() -> Void)? = nil) {
        self.task = task
        self.onToggleCompletion = onToggleCompletion
        self.onEdit = onEdit
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion checkbox
            Button(action: onToggleCompletion) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .secondary)
                    .font(.title3)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // Task content
            VStack(alignment: .leading, spacing: 4) {
                // Task title
                HStack(spacing: 6) {
                    Text(task.title)
                        .strikethrough(task.isCompleted)
                        .foregroundColor(task.isCompleted ? .secondary : .primary)
                    
                    // Priority indicator
                    if task.priority == .high {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else if task.priority == .low {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                // Metadata row
                HStack(spacing: 8) {
                    // Due date (if present)
                    if let dueDate = task.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(dateFormatter.string(from: dueDate))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Category (if present)
                    if let category = task.category {
                        HStack(spacing: 4) {
                            Image(systemName: "tag.fill")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(category)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                onEdit?()
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onToggleCompletion()
        }
    }
}

#Preview {
    List {
        TaskRowView(
            task: Task(
                title: "Complete project documentation",
                isCompleted: false,
                dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())
            ),
            onToggleCompletion: {},
            onEdit: {}
        )
        TaskRowView(
            task: Task(
                title: "Review code changes",
                isCompleted: true
            ),
            onToggleCompletion: {},
            onEdit: {}
        )
    }
    .frame(width: 400, height: 200)
}
