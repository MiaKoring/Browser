//
//  AppViewModel.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//
import SwiftData
import SwiftUI
import WebKit
import MeiliSearch

@Observable
class AppViewModel: NSObject, ObservableObject, NSWindowDelegate {
    var currentlyActiveWindowId: String = ""
    var displayedWindows: Set<String> = []
    var openWindow: ((URL) -> Void)? = nil
    var openMiniInNewTab: ((URL?, String, Bool) -> Void)? = nil
    var openWindowByID: ((String) -> Void)? = nil
    var highlightedWindow: String = ""
    var modelContainer: ModelContainer? = nil
    var showMeiliSetup = false
    var meili: MeiliSearch?
    var downloadManager = DownloadManager()
    var shouldSkipMeiliNotification: Bool = false
    
    func windowDidBecomeKey(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            if let id = window.identifier?.rawValue {
                currentlyActiveWindowId = id
            }
        }
    }
    
    static func isDefaultBrowser() -> Bool {
        guard let url = URL(string: "https://amethyst.miakoring.de"), let appURL = NSWorkspace.shared.urlForApplication(toOpen: url) else { return false }
        
        
        return appURL.absoluteString.contains("Amethyst%20Browser.app")
    }
}
