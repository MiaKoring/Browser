//
//  TabMigration.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 29.11.24.
//

import SwiftData

enum TabMigration: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SavedTabSchemaV0_1.self, SavedTabSchemaV0_1_1.self]
    }
    static var stages: [MigrationStage] = [v0_1Tov0_1_0]
    
    static var v0_1Tov0_1_0: MigrationStage = MigrationStage.custom(
        fromVersion: SavedTabSchemaV0_1.self,
        toVersion: SavedTabSchemaV0_1_1.self,
        willMigrate: { context in
            let tabs = try context.fetch(FetchDescriptor<SavedTabSchemaV0_1.SavedTab>())
            let new = {
                for tab in tabs {
                    context.delete(tab)
                    context.insert(SavedTabSchemaV0_1_1.SavedTab(id: tab.id, sortingID: tab.sortingID, url: tab.url, windowID: "window1"))
                }
            }
    }, didMigrate: nil)
}
