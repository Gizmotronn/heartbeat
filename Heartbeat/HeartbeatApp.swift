//
//  HeartbeatApp.swift
//  Heartbeat
//
//  Created by Liam Arbuckle on 8/1/2026.
//

import SwiftUI
import SwiftData

@main
struct HeartbeatApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            DatePerson.self,
            PreviousDate.self,
            EmotionEntry.self,
            Gift.self,
            PhysicalTouchMoment.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Schema migration failed - delete old store and create fresh one
            print("ModelContainer creation failed: \(error). Attempting to delete old store...")
            
            let url = URL.applicationSupportDirectory.appending(path: "default.store")
            let urls = [
                url,
                url.appendingPathExtension("shm"),
                url.appendingPathExtension("wal")
            ]
            
            for fileURL in urls {
                try? FileManager.default.removeItem(at: fileURL)
            }
            
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer after reset: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
