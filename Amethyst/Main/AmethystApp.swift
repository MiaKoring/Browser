//
//  BrowserApp.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//

import SwiftUI
import AppKit

@main
struct AmethystApp: App {
    @State var appViewModel = AppViewModel()
    
    
    var body: some Scene {
        Window("Amethyst", id: "ioi") {
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
            CommandGroup(after: .sidebar) {
                Button("Toggle Sidebar") {
                    withAnimation(.linear(duration: 0.1)) {
                        appViewModel.isSidebarShown.toggle()
                    }
                }
                .keyboardShortcut("e", modifiers: .command)
            }
            CommandMenu("Navigation") {
                Button("New Tab") {
                    appViewModel.triggerNewTab.toggle()
                }
                .keyboardShortcut("t", modifiers: .command)
                if let model = appViewModel.tabs.first(where: {$0.id == appViewModel.currentTab})?.webViewModel {
                    Button("Go Back") {
                        model.goBack()
                    }
                    .keyboardShortcut("Ö", modifiers: .command)
                    Button("Go Forward") {
                        model.goForward()
                    }
                    .keyboardShortcut("Ä", modifiers: .command)
                }
            }
        }
    }
}
