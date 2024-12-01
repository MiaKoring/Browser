//
//  Tab.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//

import WebKit

struct ATab: Hashable, Equatable, Identifiable {
    var id: UUID
    var webViewModel: WebViewModel
    var restoredURLs: [BackForwardListItem]
    
    init(id: UUID = UUID(), webViewModel: WebViewModel, restoredURLs: [BackForwardListItem] = []) {
        self.id = id
        self.webViewModel = webViewModel
        self.restoredURLs = restoredURLs
    }
    
    static func ==(lhs: ATab, rhs: ATab) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
