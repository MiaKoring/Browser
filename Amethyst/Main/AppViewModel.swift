//
//  AppViewModel.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//
import SwiftUI
import WebKit

@Observable
class AppViewModel: NSObject, ObservableObject, NSWindowDelegate {
    var currentlyActiveWindowId: String = ""
    var displayedWindows: Set<String> = []
    var openWindow: ((URL) -> Void)? = nil
    var openMiniInNewTab: ((URL?, String, Bool) -> Void)? = nil
    var openWindowByID: ((String) -> Void)? = nil
    var highlightedWindow: String = ""
    
    func windowDidBecomeKey(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            if let id = window.identifier?.rawValue {
                currentlyActiveWindowId = id
            }
        }
      }
}
