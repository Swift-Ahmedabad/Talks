//
//  TaskEditView.swift
//  tasks
//
//  Created by Personal on 12/12/25.
//

import SwiftUI

/// View for creating or editing a task
/// Can be used in both create mode (task is nil) and edit mode (task is provided)
struct TaskEditView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String
    @State private var dueDate: Date?
    @State private var hasDueDate: Bool
    @State private var notes: String
    @State private var priority: TaskPriority
    @State private var category: String
    
    /// The task being edited, or nil for new tasks
    let task: Task?
    /// Callback invoked when the user saves the task
    let onSave: (Task) -> Void
    
    init(task: Task? = nil, onSave: @escaping (Task) -> Void) {
        self.task = task
        self.onSave = onSave
        
        // Initialize state with existing task data or defaults
        _title = State(initialValue: task?.title ?? "")
        _dueDate = State(initialValue: task?.dueDate)
        _hasDueDate = State(initialValue: task?.dueDate != nil)
        _notes = State(initialValue: task?.notes ?? "")
        _priority = State(initialValue: task?.priority ?? .medium)
        _category = State(initialValue: task?.category ?? "")
    }
    
    private var isEditing: Bool {
        task != nil
    }
    
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(.headline)
                TextField("Enter task title", text: $title)
                    .textFieldStyle(.roundedBorder)
            }
            
            // Due Date
            VStack(alignment: .leading, spacing: 8) {
                Toggle("Set due date", isOn: $hasDueDate)
                    .font(.headline)
                
                if hasDueDate {
                    DatePicker(
                        "Due Date",
                        selection: Binding(
                            get: { dueDate ?? Date() },
                            set: { dueDate = $0 }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                }
            }
            .onChange(of: hasDueDate) { _, newValue in
                if !newValue {
                    dueDate = nil
                } else if dueDate == nil {
                    dueDate = Date()
                }
            }
            
            // Priority
            VStack(alignment: .leading, spacing: 8) {
                Text("Priority")
                    .font(.headline)
                Picker("Priority", selection: $priority) {
                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                        Text(priority.rawValue).tag(priority)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Category
            VStack(alignment: .leading, spacing: 8) {
                Text("Category")
                    .font(.headline)
                TextField("Category (optional)", text: $category)
                    .textFieldStyle(.roundedBorder)
            }
            
            // Notes
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes")
                    .font(.headline)
                TextEditor(text: $notes)
                    .frame(minHeight: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
            }
            
            Spacer()
            
            // Action buttons
            HStack {
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button(isEditing ? "Save" : "Create") {
                    saveTask()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!isValid)
            }
        }
        .padding()
        .frame(width: 500, height: 500)
        .onAppear {
            // Ensure fields are prefilled when editing a task
            if let task = task {
                title = task.title
                dueDate = task.dueDate
                hasDueDate = task.dueDate != nil
                notes = task.notes ?? ""
                priority = task.priority
                category = task.category ?? ""
            }
        }
    }
    
    private func saveTask() {
        guard isValid else { return }
        
        let taskToSave: Task
        if let existingTask = task {
            // Update existing task
            taskToSave = Task(
                id: existingTask.id,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                isCompleted: existingTask.isCompleted,
                createdDate: existingTask.createdDate,
                dueDate: hasDueDate ? dueDate : nil,
                notes: notes.isEmpty ? nil : notes,
                priority: priority,
                category: category.isEmpty ? nil : category
            )
        } else {
            // Create new task
            taskToSave = Task(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                isCompleted: false,
                dueDate: hasDueDate ? dueDate : nil,
                notes: notes.isEmpty ? nil : notes,
                priority: priority,
                category: category.isEmpty ? nil : category
            )
        }
        
        onSave(taskToSave)
        dismiss()
    }
}

#Preview("Create Mode") {
    TaskEditView(onSave: { _ in })
}

#Preview("Edit Mode") {
    TaskEditView(
        task: Task(
            title: "Sample Task",
            isCompleted: false,
            dueDate: Date(),
            notes: "Some notes here"
        ),
        onSave: { _ in }
    )
}
