//
//  Tab.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//

import WebKit

struct ATab: Hashable, Equatable {
    var id: UUID = UUID()
    var webViewModel: WebViewModel
    
    static func ==(lhs: ATab, rhs: ATab) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
