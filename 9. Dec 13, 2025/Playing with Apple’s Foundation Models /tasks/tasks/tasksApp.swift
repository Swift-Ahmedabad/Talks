//
//  tasksApp.swift
//  tasks
//
//  Created by Personal on 12/12/25.
//

import SwiftUI

/// Main application entry point
@main
struct tasksApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 600, height: 500)
        .commands {
            // Additional menu commands can be added here
        }
    }
}
