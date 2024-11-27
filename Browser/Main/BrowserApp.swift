//
//  BrowserApp.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//

import SwiftUI
import AppKit

@main
struct BrowserApp: App {
    @State var appViewModel = AppViewModel()
    
    var body: some Scene {
        Window("Browser", id: "ioi") {
            ContentView()
                .frame(minWidth: 600, minHeight: 400)
                .ignoresSafeArea(.container, edges: .top)
                .onAppear {
                    if let window = NSApp.windows.first {
                        window.standardWindowButton(.closeButton)?.isHidden = true
                        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                        window.standardWindowButton(.zoomButton)?.isHidden = true
                    }
                }
                .environment(appViewModel)
        }
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Tab") {
                    appViewModel.triggerNewTab.toggle()
                }
                .keyboardShortcut("t", modifiers: .command)
            }
        }
    }
}

