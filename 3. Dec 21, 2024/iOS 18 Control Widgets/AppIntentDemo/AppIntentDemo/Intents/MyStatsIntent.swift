//
//  AppIntent.swift
//  AppIntentDemo
//
//  Created by Jay Kothadia on 15/12/24.
//

import Foundation
import AppIntents
import UIKit

struct MyStatsIntent: AppIntent {
    static var title: LocalizedStringResource = "My Stats"
    static var description = IntentDescription("Shows your stats in the app")
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        AppGroup(identifier: .controlCentre).userDefaults?.set("myApp://displayInput/helloWorld", forKey: SharedManager.shared.pageToOpen)
        AppDelegate.shared.intentMessage = "hello wrold"
        return .result()
    }
}
