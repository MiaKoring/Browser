//
//  BrowserApp.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//

import SwiftUI
import AppKit
import SwiftData


@main
struct AmethystApp: App {
    @State var appViewModel = AppViewModel()
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: SavedTab.self, migrationPlan: TabMigration.self)
        } catch {
            fatalError("failed to initialize model container")
        }
    }
    
    var body: some Scene {
        Window("Amethyst Browser", id: "ioi") {
            ContentView()
                .frame(minWidth: 600, minHeight: 400)
                .ignoresSafeArea(.container, edges: .top)
                .modelContainer(container)
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
                        if appViewModel.isSidebarFixed {
                            appViewModel.isSidebarFixed = false
                            appViewModel.isSidebarShown = false
                        } else {
                            appViewModel.isSidebarShown.toggle()
                        }
                    }
                }
                .keyboardShortcut("e", modifiers: .command)
                Button("Fix Sidebar") {
                    appViewModel.isSidebarShown = false
                    withAnimation(.linear(duration: 0.1)) {
                        appViewModel.isSidebarFixed.toggle()
                    }
                }
                .keyboardShortcut("f", modifiers: [.command, .shift])
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
                Button("Previous Tab") {
                    guard let index = appViewModel.tabs.firstIndex(where: {$0.id == appViewModel.currentTab}) else {
                        appViewModel.currentTab = appViewModel.tabs[0].id
                        return
                    }
                    appViewModel.currentTab = appViewModel.tabs[max(0, index - 1)].id
                }
                .keyboardShortcut("w", modifiers: .command)
                .disabled(appViewModel.tabs.count < 1 || appViewModel.tabs.firstIndex(where: {$0.id == appViewModel.currentTab}) == 0)
                Button("Next Tab") {
                    guard let index = appViewModel.tabs.firstIndex(where: {$0.id == appViewModel.currentTab}) else {
                        appViewModel.currentTab = appViewModel.tabs[appViewModel.tabs.count - 1].id
                        return
                    }
                    appViewModel.currentTab = appViewModel.tabs[min(appViewModel.tabs.count - 1, index + 1)].id
                }
                .keyboardShortcut("s", modifiers: .command)
                .disabled(appViewModel.tabs.count < 1 || appViewModel.tabs.firstIndex(where: {$0.id == appViewModel.currentTab}) == appViewModel.tabs.count - 1)
                Button("Close current Tab") {
                    guard let index = appViewModel.tabs.firstIndex(where: {$0.id == appViewModel.currentTab}) else { return }
                    if appViewModel.tabs.count > 1 {
                        let before = appViewModel.tabs[max(0, index - 1)].id
                        let after = appViewModel.tabs[min(appViewModel.tabs.count - 1, index + 1)].id
                        appViewModel.currentTab = before == appViewModel.currentTab ? after : before
                    } else {
                        appViewModel.currentTab = nil
                    }
                    withAnimation(.linear(duration: 0.2)) {
                        appViewModel.tabs[index].webViewModel.deinitialize()
                        appViewModel.tabs.remove(at: index)
                    }
                }
                .keyboardShortcut("c", modifiers: .option)
                .disabled(appViewModel.currentTab == nil)
            }
        }
    }
}
