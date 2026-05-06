//
//  SmartTaskCreationView.swift
//  tasks
//
//  Created by Personal on 12/12/25.
//

import SwiftUI

/// View for creating tasks using natural language input with AI parsing
struct SmartTaskCreationView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var service = SmartTaskService()
    
    @State private var naturalLanguageInput: String = ""
    @State private var parsedData: ParsedTaskData?
    @State private var errorMessage: String?
    @State private var showingManualCreation = false
    
    /// Callback invoked when the user saves the task
    let onSave: (Task) -> Void
    
    private enum ViewState {
        case input
        case loading
        case parsed
        case error
    }
    
    private var currentState: ViewState {
        if service.isProcessing {
            return .loading
        } else if parsedData != nil {
            return .parsed
        } else if errorMessage != nil {
            return .error
        } else {
            return .input
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.accentColor)
                    .font(.title2)
                Text("Smart Task Creation")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 8)
            
            Divider()
            
            // Content based on state
            switch currentState {
            case .input:
                inputView
            case .loading:
                loadingView
            case .parsed:
                parsedReviewView
            case .error:
                errorView
            }
        }
        .padding()
        .frame(width: 600, height: 500)
        .sheet(isPresented: $showingManualCreation) {
            TaskEditView { task in
                onSave(task)
                dismiss()
            }
        }
    }
    
    // MARK: - Input View
    
    private var inputView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Describe your task in natural language:")
                .font(.headline)
            
            TextEditor(text: $naturalLanguageInput)
                .frame(minHeight: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
                .font(.body)
            
            if !service.isModelAvailable {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("AI Model Initializing")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    Text("The AI model is still loading. Please wait a moment before creating tasks.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
            
            HStack {
                Spacer()
                Button("Switch to Manual Creation") {
                    showingManualCreation = true
                }
                .buttonStyle(.plain)
                
                Button("Parse Task") {
                    parseTask()
                }
                .buttonStyle(.borderedProminent)
                .disabled(naturalLanguageInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Analyzing your task...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Parsed Review View
    
    private var parsedReviewView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Review and edit the extracted information:")
                    .font(.headline)
                
                if let parsed = parsedData {
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        TextField("Task title", text: Binding(
                            get: { parsed.title },
                            set: { parsedData?.title = $0 }
                        ))
                        .textFieldStyle(.roundedBorder)
                    }
                    
                    // Due Date
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Set due date", isOn: Binding(
                            get: { parsed.dueDate != nil },
                            set: { hasDate in
                                if hasDate {
                                    let formatter = ISO8601DateFormatter()
                                    formatter.formatOptions = [.withInternetDateTime]
                                    parsedData?.dueDate = formatter.string(from: Date())
                                } else {
                                    parsedData?.dueDate = nil
                                }
                            }
                        ))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        
                        if let dueDateString = parsed.dueDate {
                            let dateFormatter: ISO8601DateFormatter = {
                                let f = ISO8601DateFormatter()
                                f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                                return f
                            }()
                            
                            DatePicker(
                                "Due Date",
                                selection: Binding(
                                    get: {
                                        if let date = dateFormatter.date(from: dueDateString) {
                                            return date
                                        }
                                        let fallbackFormatter = ISO8601DateFormatter()
                                        fallbackFormatter.formatOptions = [.withInternetDateTime]
                                        return fallbackFormatter.date(from: dueDateString) ?? Date()
                                    },
                                    set: { newDate in
                                        parsedData?.dueDate = dateFormatter.string(from: newDate)
                                    }
                                ),
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(.compact)
                        }
                    }
                    
                    // Priority
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Priority")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Picker("Priority", selection: Binding(
                            get: { TaskPriority(rawValue: parsed.priority) ?? .medium },
                            set: { parsedData?.priority = $0.rawValue }
                        )) {
                            ForEach(TaskPriority.allCases, id: \.self) { priority in
                                Text(priority.rawValue).tag(priority)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        TextField("Category (optional)", text: Binding(
                            get: { parsed.category ?? "" },
                            set: { parsedData?.category = $0.isEmpty ? nil : $0 }
                        ))
                        .textFieldStyle(.roundedBorder)
                    }
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        TextEditor(text: Binding(
                            get: { parsed.notes ?? "" },
                            set: { parsedData?.notes = $0.isEmpty ? nil : $0 }
                        ))
                        .frame(minHeight: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                
                // Action buttons
                HStack {
                    Button("Start Over") {
                        resetView()
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                    
                    Button("Create Task") {
                        createTask()
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
                }
            }
        }
    }
    
    // MARK: - Error View
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Failed to Parse Task")
                .font(.headline)
            
            if let error = errorMessage {
                Text(error)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            VStack(spacing: 12) {
                Button("Try Again") {
                    errorMessage = nil
                    parseTask()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Switch to Manual Creation") {
                    showingManualCreation = true
                }
                .buttonStyle(.bordered)
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Actions
    
    private func parseTask() {
        errorMessage = nil
        parsedData = nil
        
        // Use concurrency Task (not the custom Task struct)
        _Concurrency.Task {
            do {
                let parsed = try await service.parseTaskFromNaturalLanguage(naturalLanguageInput)
                await MainActor.run {
                    parsedData = parsed
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func createTask() {
        guard let parsed = parsedData else { return }
        let task = parsed.toTask()
        onSave(task)
        dismiss()
    }
    
    private func resetView() {
        naturalLanguageInput = ""
        parsedData = nil
        errorMessage = nil
    }
}

#Preview {
    SmartTaskCreationView(onSave: { _ in })
}

