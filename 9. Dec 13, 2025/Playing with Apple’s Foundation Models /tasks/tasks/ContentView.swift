//
//  ContentView.swift
//  tasks
//
//  Created by Personal on 12/12/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var taskManager = TaskManager()
    @State private var showingEditView = false
    @State private var showingSmartCreateView = false
    @State private var editingTask: Task?
    @State private var taskToDelete: Task?
    @State private var showingDeleteConfirmation = false
    @State private var selectedTask: Task?
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchAndFilterBar
                Divider()
                taskListView
            }
            .navigationTitle("Tasks")
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $showingEditView) {
                editView
            }
            .sheet(isPresented: $showingSmartCreateView) {
                SmartTaskCreationView { newTask in
                    taskManager.addTask(newTask)
                }
            }
            .alert("Delete Task", isPresented: $showingDeleteConfirmation) {
                deleteConfirmationButtons
            } message: {
                if let task = taskToDelete {
                    Text("Are you sure you want to delete \"\(task.title)\"?")
                }
            }
        }
        .frame(minWidth: 400, minHeight: 300)
    }
    
    // MARK: - View Components
    
    private var searchAndFilterBar: some View {
        VStack(spacing: 12) {
            searchField
            filterButtons
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search tasks...", text: $taskManager.searchQuery)
                .textFieldStyle(.plain)
                .focused($isSearchFocused)
                .onSubmit {
                    isSearchFocused = false
                }
            
            if !taskManager.searchQuery.isEmpty {
                Button(action: {
                    taskManager.clearSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(6)
    }
    
    private var filterButtons: some View {
        HStack(spacing: 4) {
            ForEach(TaskFilter.allCases, id: \.self) { filter in
                filterButton(for: filter)
            }
        }
    }
    
    private func filterButton(for filter: TaskFilter) -> some View {
        Button(action: {
            taskManager.currentFilter = filter
        }) {
            Text(filter.rawValue)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .background(
            taskManager.currentFilter == filter
                ? Color.accentColor.opacity(0.2)
                : Color(NSColor.controlBackgroundColor)
        )
        .foregroundColor(
            taskManager.currentFilter == filter
                ? .accentColor
                : .primary
        )
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(
                    taskManager.currentFilter == filter
                        ? Color.accentColor
                        : Color.clear,
                    lineWidth: 1
                )
        )
    }
    
    @ViewBuilder
    private var taskListView: some View {
        if taskManager.filteredTasks.isEmpty {
            emptyStateView
        } else {
            taskList
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: taskManager.tasks.isEmpty ? "checklist" : "magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            Text(taskManager.tasks.isEmpty ? "No Tasks" : "No Results")
                .font(.title2)
                .foregroundColor(.secondary)
            Text(taskManager.tasks.isEmpty 
                 ? "Click the + button to add your first task"
                 : "Try adjusting your search or filter")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var taskList: some View {
        List(selection: $selectedTask) {
            ForEach(taskManager.filteredTasks) { task in
                TaskRowView(
                    task: task,
                    onToggleCompletion: {
                        taskManager.toggleTaskCompletion(task)
                    },
                    onEdit: {
                        editingTask = task
                        showingEditView = true
                    }
                )
                .tag(task)
                .contextMenu {
                    Button("Edit") {
                        editingTask = task
                        showingEditView = true
                    }
                    Button("Delete", role: .destructive) {
                        taskToDelete = task
                        showingDeleteConfirmation = true
                    }
                }
            }
            .onDelete { indexSet in
                let tasksToDelete = indexSet.map { taskManager.filteredTasks[$0] }
                for task in tasksToDelete {
                    taskManager.deleteTask(task)
                }
            }
        }
        .onDeleteCommand {
            if let task = selectedTask {
                taskToDelete = task
                showingDeleteConfirmation = true
            }
        }
        .focusable()
        .onKeyPress(.space) {
            if let task = selectedTask, !isSearchFocused {
                taskManager.toggleTaskCompletion(task)
                return .handled
            }
            return .ignored
        }
        .onKeyPress(.return) {
            if let task = selectedTask, !isSearchFocused {
                taskManager.toggleTaskCompletion(task)
                return .handled
            }
            return .ignored
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            HStack(spacing: 8) {
                Button(action: {
                    showingSmartCreateView = true
                }) {
                    Image(systemName: "sparkles")
                }
                .help("Smart Create (⌘⇧N)")
                .keyboardShortcut("n", modifiers: [.command, .shift])
                
                Button(action: {
                    editingTask = nil
                    showingEditView = true
                }) {
                    Image(systemName: "plus")
                }
                .help("New Task (⌘N)")
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        ToolbarItem(placement: .automatic) {
            Button(action: {
                isSearchFocused = true
            }) {
                Image(systemName: "magnifyingglass")
            }
            .help("Search (⌘F)")
            .keyboardShortcut("f", modifiers: .command)
        }
        ToolbarItem(placement: .automatic) {
            Button(action: {
                if let task = selectedTask {
                    editingTask = task
                    showingEditView = true
                }
            }) {
                Image(systemName: "pencil")
            }
            .help("Edit Task (⌘E)")
            .keyboardShortcut("e", modifiers: .command)
            .disabled(selectedTask == nil)
        }
    }
    
    @ViewBuilder
    private var editView: some View {
        if let task = editingTask {
            TaskEditView(task: task) { updatedTask in
                taskManager.updateTask(updatedTask)
            }
        } else {
            TaskEditView { newTask in
                taskManager.addTask(newTask)
            }
        }
    }
    
    @ViewBuilder
    private var deleteConfirmationButtons: some View {
        Button("Delete", role: .destructive) {
            if let task = taskToDelete {
                taskManager.deleteTask(task)
                taskToDelete = nil
                selectedTask = nil
            }
        }
        Button("Cancel", role: .cancel) {
            taskToDelete = nil
        }
    }
}

#Preview {
    ContentView()
}
