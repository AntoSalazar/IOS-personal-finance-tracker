//
//  personal_finance_trackerApp.swift
//  personal-finance-tracker
//
//  Created by Carlos Salazar on 31/01/26.
//

import SwiftUI
import SwiftData

@main
struct personal_finance_trackerApp: App {
    @State private var container = AppContainer()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
        }
        .modelContainer(sharedModelContainer)
    }
}
