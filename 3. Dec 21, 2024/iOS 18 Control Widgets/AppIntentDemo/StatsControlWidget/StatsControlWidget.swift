//
//  StatsControlWidgetControl.swift
//  StatsControlWidget
//
//  Created by Jay Kothadia on 15/12/24.
//

import AppIntents
import SwiftUI
import WidgetKit

struct StatsControlWidget: ControlWidget {
    static let identifier: String = "com.JAY.AppIntentDemo.StatsControlWidget"
    
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: StatsControlWidget.identifier) {
            ControlWidgetButton(action: OpenAppIntent()) {
                Image(systemName: "cricket.ball")
                if let intRuns = Int(getUserRuns()), let intWickets = Int(getUserWickets()) {
                    Text(intRuns > intWickets ? "🏏  \(getUserRuns())\n🎾  \(getUserWickets())" : "🎾  \(getUserWickets())\n🏏  \(getUserRuns())")
                } else {
                    Text("🏏  \(getUserRuns())\n🎾  \(getUserWickets())")
                }
                
                if getUserRuns().contains("--") || getUserWickets().contains("--") {
                    Text("Tap to Update")
                } else {
                    Text("CricHeroes Stats")
                }
            }
        }
        .displayName("My Stats")
    }
    
    func getUserRuns() -> String {
        return (AppGroup(identifier: .controlCentre).userDefaults?.string(forKey: SharedManager.shared.userRunsKey) ?? "--") + " R"
    }
    
    func getUserWickets() -> String {
        return (AppGroup(identifier: .controlCentre).userDefaults?.string(forKey: SharedManager.shared.userWicketsKey) ?? "--") + " W"
    }
}


struct OpenAppIntent: AppIntent {
    static var title: LocalizedStringResource = "Open App Intent"
    static var description = IntentDescription("Opens the app when tapped")
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        
        return .result()
    }
}
