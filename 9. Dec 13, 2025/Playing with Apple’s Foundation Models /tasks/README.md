# Tasks - Native macOS Task Management App

A simple, native task management application built for macOS using SwiftUI.

## Overview

Tasks is a lightweight task management application designed specifically for macOS. Built with SwiftUI, it provides a clean and intuitive interface for managing your daily tasks and to-do items.

## Features

- ✅ Create, edit, and delete tasks
- ✅ Native macOS design with SwiftUI
- ✅ Local data persistence (UserDefaults with JSON encoding)
- ✅ Search and filter tasks (real-time search, filter by All/Active/Completed)
- ✅ Complete keyboard shortcuts support
  - `⌘N` - Create new task
  - `⌘F` - Focus search field
  - `⌘E` - Edit selected task
  - `Space` or `Enter` - Toggle task completion
  - `Delete` - Delete selected task
  - Arrow keys - Navigate task list

## Requirements

- macOS 12.0 or later
- Xcode 14.0 or later (for development)
- Swift 5.7 or later

## Getting Started

### Building the Project

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd tasks
   ```

2. Open the project in Xcode:
   ```bash
   open tasks.xcodeproj
   ```

3. Select your target device (Mac) and build the project:
   - Press `Cmd + B` to build
   - Press `Cmd + R` to run

### Running the App

1. Build and run the project from Xcode
2. The app will launch in a new window

## Project Structure

```
tasks/
├── tasks/
│   ├── tasksApp.swift       # Main app entry point
│   ├── ContentView.swift    # Main view with task list
│   ├── Task.swift           # Task data model
│   ├── TaskManager.swift    # Task management and persistence
│   ├── TaskRowView.swift    # Task row component
│   ├── TaskEditView.swift   # Task create/edit form
│   └── Assets.xcassets/     # App assets and icons
└── tasks.xcodeproj/         # Xcode project file
```

## Development

This project uses:
- **SwiftUI** for the user interface
- **Swift** as the programming language
- **UserDefaults** for local data persistence
- Native macOS frameworks

### Current Implementation Status

**✅ All Phases Complete:**
- ✅ Phase 1: Data Model & Architecture
- ✅ Phase 2: Core UI Components
- ✅ Phase 3: CRUD Operations
- ✅ Phase 4: Search & Filter
- ✅ Phase 5: Keyboard Shortcuts
- ✅ Phase 6: Polish & macOS Native Features
- ✅ Phase 7: Testing & Refinement
- ✅ Phase 8: Documentation & Cleanup

The application is fully functional with all planned features implemented and documented.

### Usage

**Creating and Editing:**
- **Create Task:** Click the "+" button in the toolbar or press `⌘N`
- **Edit Task:** Double-click a task, right-click and select "Edit", or select a task and press `⌘E`

**Managing Tasks:**
- **Toggle Completion:** Click the checkbox, single-click the task row, or select and press `Space`/`Enter`
- **Delete Task:** Right-click and select "Delete", select and press `Delete` key, or swipe left on a task (with confirmation dialog)

**Search and Filter:**
- **Search Tasks:** Type in the search field or press `⌘F` to focus it
- **Filter Tasks:** Click filter buttons (All, Active, Completed) to filter by completion status
- **Clear Search:** Click the X button in the search field to clear your search
- **Combine Search & Filter:** Search and filter work together - you can search within filtered results

**Navigation:**
- Use arrow keys to navigate through tasks
- Selected task is highlighted
- All keyboard shortcuts work globally in the app

### Technical Details

**Architecture:**
- MVVM pattern with `TaskManager` as the `ObservableObject` for reactive state management
- SwiftUI for UI with native macOS styling
- UserDefaults with JSON encoding for persistence (ISO8601 date encoding)

**Data Model:**
- Task properties: id (UUID), title (String), isCompleted (Bool), createdDate (Date), optional dueDate (Date?), optional notes (String?)
- Tasks conform to `Identifiable` and `Codable` for SwiftUI lists and persistence

**Features:**
- Real-time search filters tasks by title (case-insensitive)
- Filter options: All tasks, Active (incomplete), or Completed tasks
- Search and filter work together - you can search within filtered results
- All CRUD operations persist automatically
- Input validation ensures non-empty task titles
- Error handling for persistence operations

**Keyboard Support:**
- Full keyboard navigation and shortcuts
- All shortcuts work globally when appropriate
- Toolbar buttons show shortcut hints
- Proper focus management for search field

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is available for personal use.

## Author

Created by Personal

