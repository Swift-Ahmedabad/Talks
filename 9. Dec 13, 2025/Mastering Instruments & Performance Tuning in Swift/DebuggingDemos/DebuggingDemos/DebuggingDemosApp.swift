//
//  DebuggingDemosApp.swift
//  DebuggingDemos
//
//  Created by Sneha Dudhat on 08/12/25.
//

import SwiftUI
import CoreData

@main
struct DebuggingDemosApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
