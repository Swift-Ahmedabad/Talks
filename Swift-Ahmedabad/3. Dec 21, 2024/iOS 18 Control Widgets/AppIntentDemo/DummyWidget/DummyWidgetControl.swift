//
//  DummyWidgetControl.swift
//  DummyWidget
//
//  Created by Jay Kothadia on 21/12/24.
//

import AppIntents
import SwiftUI
import WidgetKit
import Foundation

struct DummyWidgetControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "com.JAY.AppIntentDemo.DummyWidget",
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "Start Timer",
                isOn: value,
                action: StartTimerIntent()
            ) { isRunning in
                Label(isRunning ? "Running" : "Stopped", systemImage: "timer")
            }
        }
        .displayName("Timer")
        .description("An example control that runs a timer.")
    }
}

extension DummyWidgetControl {
    struct Provider: ControlValueProvider {
        var previewValue: Bool {
            false
        }

        func currentValue() async throws -> Bool {
            let group = AppGroup(identifier: .controlCentre)
            let defaults = group.userDefaults
            return defaults?.bool(forKey: SharedManager.shared.timerIsRunningKey) ?? false
        }
    }
}

struct StartTimerIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Start a timer"

    @Parameter(title: "Timer is running")
    var value: Bool

    func perform() async throws -> some IntentResult {
        let group = AppGroup(identifier: .controlCentre)
        let defaults = group.userDefaults
        defaults?.set(value, forKey: SharedManager.shared.timerIsRunningKey)
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
