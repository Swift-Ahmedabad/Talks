//
//  CricHeroesShortcutsProvider.swift
//  AppIntentDemo
//
//  Created by Jay Kothadia on 15/12/24.
//


import AppIntents
import SwiftUI
import Intents

struct DemoShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            AppShortcut(
                intent: MyStatsIntent(),
                phrases: [
                    "Open My stats in \(.applicationName)",
                    "Open stats in \(.applicationName)" // appliation name is necessary to get the phrase recognised
                ],
                shortTitle: "My Stats",
                systemImageName: "chart.bar.xaxis"
            )
        ]
    }
}


enum AppIntents: String {
    case my_stats
    
    var intent: any AppIntent {
        switch self {
        case .my_stats:
            MyStatsIntent()
        }
    }
    
    func donateShortcut() {
        Task(priority: .utility) {
            do {
                try await intent.donate()
                print("Successfully donated \(String(describing: self)) shortcut")
            } catch {
                print("Error donating shortcut: \(error.localizedDescription)")
            }
        }
    }
}
