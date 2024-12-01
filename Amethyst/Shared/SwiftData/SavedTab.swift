//
//  Models.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 29.11.24.
//
import Foundation
import SwiftData
import WebKit

typealias SavedTab = SavedTabSchemaV0_1_3.SavedTab
typealias BackForwardListItem = SavedTabSchemaV0_1_3.BackForwardListItem

enum SavedTabSchemaV0_1_3: VersionedSchema {
    static let versionIdentifier = Schema.Version(0, 1, 3)
    static var models: [any PersistentModel.Type] {
        [SavedTab.self]
    }
    
    @Model
    final class SavedTab {
        var id: UUID
        var sortingID: Int
        var url: URL?
        var windowID: String
        @Relationship(deleteRule: .cascade)
        var backForwardList: [BackForwardListItem]
        
        init(id: UUID, sortingID: Int, url: URL?, windowID: String, backForwardList: [BackForwardListItem]) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
            self.windowID = windowID
            self.backForwardList = backForwardList
        }
    }
    
    @Model
    final class BackForwardListItem {
        var id: UUID
        var sortingID: Int
        var url: URL?
        var title: String?
        
        init(id: UUID = UUID(), sortingID: Int, url: URL?, title: String?) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
            self.title = title
        }
    }
}

enum SavedTabSchemaV0_1_2: VersionedSchema {
    static let versionIdentifier = Schema.Version(0, 1, 2)
    static var models: [any PersistentModel.Type] {
        [SavedTab.self]
    }
    
    @Model
    final class SavedTab {
        var id: UUID
        var sortingID: Int
        var url: URL?
        var windowID: String
        var backList: [BackForwardListItem]?
        var forwardList: [BackForwardListItem]?
        
        init(id: UUID, sortingID: Int, url: URL?, windowID: String, backList: [BackForwardListItem], forwardList: [BackForwardListItem]) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
            self.windowID = windowID
            self.backList = backList
            self.forwardList = forwardList
        }
    }
    
    @Model
    final class BackForwardListItem {
        var id: UUID
        var sortingID: Int
        var url: URL
        
        init(id: UUID = UUID(), sortingID: Int, url: URL) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
        }
    }
}

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

