//
//  Models.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 29.11.24.
//
import Foundation
import SwiftData
import WebKit

typealias SavedTab = SavedTabSchemaV0_1_1.SavedTab

enum SavedTabSchemaV0_1_1: VersionedSchema {
    static let versionIdentifier = Schema.Version(0, 1, 1)
    static var models: [any PersistentModel.Type] {
        [SavedTab.self]
    }
    
    @Model
    final class SavedTab {
        var id: UUID
        var sortingID: Int
        var url: URL?
        var windowID: String?
        
        init(id: UUID, sortingID: Int, url: URL?, windowID: String) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
            self.windowID = windowID
        }
    }
}


enum SavedTabSchemaV0_1: VersionedSchema {
    static let versionIdentifier = Schema.Version(0, 1, 0)
    static var models: [any PersistentModel.Type] {
        [SavedTab.self]
    }
    
    @Model
    final class SavedTab {
        var id: UUID
        var sortingID: Int
        var url: URL?
        
        init(id: UUID, sortingID: Int, url: URL?) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
        }
    }
}
