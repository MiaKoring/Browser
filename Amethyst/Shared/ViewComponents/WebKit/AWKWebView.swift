//
//  AWKWebView.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 29.11.24.
//

import WebKit

class AWKWebView: WKWebView {
    var contextualMenuAction: ContextualMenuAction?
    
    override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
        super.willOpenMenu(menu, with: event)
        
        var items = menu.items
        // For all default menu items which open a new Window, we add custom menu items
        // to open the object in a new Tab and to add them to the bookmarks.
        for idx in (0..<items.count).reversed() {
            if let id = items[idx].identifier?.rawValue {
                if id == "WKMenuItemIdentifierOpenLinkInNewWindow" ||
                    id == "WKMenuItemIdentifierOpenImageInNewWindow" ||
                    id == "WKMenuItemIdentifierOpenMediaInNewWindow" ||
                    id == "WKMenuItemIdentifierOpenFrameInNewWindow" {
                    
                    let object:String
                    if id == "WKMenuItemIdentifierOpenLinkInNewWindow" {
                        object = "Link"
                    } else if id == "WKMenuItemIdentifierOpenImageInNewWindow" {
                        object = "Image"
                    } else if id == "WKMenuItemIdentifierOpenMediaInNewWindow" {
                        object = "Video"
                    } else {
                        object = "Frame"
                    }
                    
                    let action = #selector(processMenuItem(_:))
                    
                    let backgroundTitle = "Open \(object) in Background"
                    let backgroundMenuItem = NSMenuItem(title: backgroundTitle, action:action, keyEquivalent:"")
                    backgroundMenuItem.identifier = NSUserInterfaceItemIdentifier("openInBackground")
                    backgroundMenuItem.target = self
                    backgroundMenuItem.representedObject = items[idx]
                    items.insert(backgroundMenuItem, at: idx + 1)
                    
                    let title = "Open \(object) in New Tab"
                    let tabMenuItem = NSMenuItem(title:title, action:action, keyEquivalent:"")
                    tabMenuItem.identifier = NSUserInterfaceItemIdentifier("openInNewTab")
                    tabMenuItem.target = self
                    tabMenuItem.representedObject = items[idx]
                    items.insert(tabMenuItem, at: idx)
                
                    /*
                    let title2 = "Add \(object) to Bookmarks"
                    let bookmarkMenuItem = NSMenuItem(title:title2, action:action, keyEquivalent:"")
                    bookmarkMenuItem.identifier = NSUserInterfaceItemIdentifier("addToBookmarks")
                    bookmarkMenuItem.target = self
                    bookmarkMenuItem.representedObject = items[idx]
                    items.insert(bookmarkMenuItem, at: idx+2)*/
                }
            }
        }
        
        menu.items = items
    }
    
    override func didCloseMenu(_ menu: NSMenu, with event: NSEvent?) {
        super.didCloseMenu(menu, with: event)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.contextualMenuAction = nil
        }
    }
    
    @objc func processMenuItem(_ menuItem: NSMenuItem) {
        self.contextualMenuAction = nil
        
        if let originalMenu = menuItem.representedObject as? NSMenuItem {
            if menuItem.identifier?.rawValue == ContextualMenuAction.openInNewTab.rawValue {
                self.contextualMenuAction = .openInNewTab
            } else if menuItem.identifier?.rawValue == ContextualMenuAction.openInBackground.rawValue {
                self.contextualMenuAction = .openInBackground
            }
            
            if let action = originalMenu.action {
                _ = originalMenu.target?.perform(action, with: originalMenu)
            }
        }
    }
}
