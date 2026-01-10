//
//  NextWidgetControl.swift
//  NextWidget
//
//  Created by Liam Arbuckle on 9/1/2026.
//

import AppIntents
import SwiftUI
import WidgetKit

struct NextWidgetControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "fromscroobles.Heartbeat.NextWidget.Control",
            provider: Provider()
        ) { value in
            ControlWidgetButton(action: OpenHeartbeatAppIntent()) {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.pink)
                    Text("Next Date")
                        .font(.caption2.weight(.semibold))
                }
            }
        }
        .displayName("Quick Open")
        .description("Open Heartbeat app quickly to manage your dates.")
    }
}

extension NextWidgetControl {
    struct Provider: ControlValueProvider {
        var previewValue: Bool {
            false
        }

        func currentValue() async throws -> Bool {
            // This control doesn't need a changing value
            return false
        }
    }
}

struct OpenHeartbeatAppIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Heartbeat"
    static let description = IntentDescription("Opens the Heartbeat app")
    
    func perform() async throws -> some IntentResult {
        // This will open the main Heartbeat app
        return .result()
    }
}