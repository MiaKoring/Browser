//
//  BrowserApp.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//

import SwiftUI
import AppKit
import SwiftData
import WebKit


@main
struct AmethystApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openWindow) var openWindow
    @State var appViewModel: AppViewModel
    @State var contentViewModel = ContentViewModel(id: "window1")
    @State var contentViewModel2 = ContentViewModel(id: "window2")
    @State var contentViewModel3 = ContentViewModel(id: "window3")
    let container: ModelContainer
    
    
    
    init() {
        do {
            container = try ModelContainer(for: SavedTab.self, migrationPlan: TabMigration.self)
        } catch {
            fatalError("failed to initialize model container")
        }
        self.appViewModel = AppViewModel()
    }
    
    
    
    var body: some Scene {
        createWindow(id: "window1", viewModel: contentViewModel)
        WindowGroup(id: "singleWindow", for: URL.self) { value in
            if let _ = value.wrappedValue {
                SingleFrame(appViewModel: appViewModel, url: value)
                    .environment(appViewModel)
                    .environment(contentViewModel)
                    .onAppear() {
                        onAppear()
                    }
                    .ignoresSafeArea()
            }
        }
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
        .windowStyle(.hiddenTitleBar)
        createWindow(id: "window2", viewModel: contentViewModel2)
        createWindow(id: "window3", viewModel: contentViewModel3)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Window") {
                    createNewWindow()
                }.keyboardShortcut("N", modifiers: [.command])
            }
            CommandGroup(after: .sidebar) {
                Button("Toggle Sidebar") {
                    toggleSidebar()
                }
                .keyboardShortcut("e", modifiers: .command)
                Button("Fix Sidebar") {
                    toggleSidebar(fix: true)
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])
            }
            CommandMenu("Navigation") {
                Button("New Tab") {
                    newTab()
                }
                .keyboardShortcut("t", modifiers: .command)
                Button("Go Back") {
                    navigate()
                }
                .keyboardShortcut("Ö", modifiers: .command)
                Button("Go Forward") {
                    navigate(back: false)
                }
                .keyboardShortcut("Ä", modifiers: .command)
                Button("Previous Tab") {
                    navigateTabs()
                }
                .keyboardShortcut("w", modifiers: [.command, .shift])
                .disabled(tabSwitchingDisabled())
                Button("Next Tab") {
                    navigateTabs(back: false)
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
                .disabled(tabSwitchingDisabled(back: false))
                Button("Close current Tab") {
                    closeCurrentTab()
                }
                .keyboardShortcut("c", modifiers: .option)
                .disabled(contentViewModel(for: appViewModel.currentlyActiveWindowId)?.currentTab == nil)
            }
        }
    }
}

