//
//  KeybindsGroup.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 13.12.24.
//

enum KeybindsGroup: String, CaseIterable {
    case window = "Window"
    case sidebar = "Sidebar"
    case search = "Search"
    case navigation = "Navigation"
    case archive = "Archive"
    case view = "View"
}

extension KeybindsGroup {
    var children: [UDKey] {
        switch self {
        case .window:
            [.newWindowShortcut]
        case .sidebar:
            [.toggleSidebarShortcut, .toggleSidebarFixedShortcut]
        case .search:
            [.openSearchbarShortcut, .openInlineSearchShortcut]
        case .view:
            [.zoomInShortcut, .zoomOutShortcut, .resetZoomShortcut]
        case .navigation:
            [.goBackShortcut, .goForwardShortcut, .reloadShortcut, .reloadFromSourceShortcut, .previousTabShortcut, .nextTabShortcut, .closeCurrentTabShortcut]
        case .archive:
            [.showHistoryShortcut, .showRestoredTabhistoryShortcut]
        }
    }
}
