//
//  IRL_RPGApp.swift
//  IRL-RPG
//
//  Created by Brad Doering on 1/3/26.
//

import SwiftUI
import CoreData

@main
struct IRL_RPGApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
