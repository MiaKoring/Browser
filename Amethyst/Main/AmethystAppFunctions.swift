//
//  AmethystAppFunctions.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 30.11.24.
//

import SwiftUI
import MeiliSearch

extension AmethystApp {
    func createNewWindow() {
        if !appViewModel.displayedWindows.contains("window1") {
            contentViewModel.currentTab = contentViewModel.tabs.first?.id
            openWindow(id: "window1")
        } else if !appViewModel.displayedWindows.contains("window2") {
            contentViewModel2.currentTab = contentViewModel.tabs.first?.id
            openWindow(id: "window2")
        } else if !appViewModel.displayedWindows.contains("window3") {
            contentViewModel3.currentTab = contentViewModel.tabs.first?.id
            openWindow(id: "window3")
        }
    }
    
    func toggleSidebar(fix: Bool = false) {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId) else { return }
        if !fix {
            withAnimation(.linear(duration: 0.1)) {
                if contentViewModel.isSidebarFixed {
                    contentViewModel.isSidebarFixed = false
                    contentViewModel.isSidebarShown = false
                } else {
                    contentViewModel.isSidebarShown.toggle()
                }
            }
            return
        }
        contentViewModel.isSidebarShown = false
        withAnimation(.linear(duration: 0.1)) {
            contentViewModel.isSidebarFixed.toggle()
        }
    }
    
    func newTab() {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId) else { return }
        contentViewModel.triggerNewTab.toggle()
    }
    
    func navigate(back: Bool = true) {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId) else { return }
        if let model = contentViewModel.tabs.first(where: {$0.id == contentViewModel.currentTab})?.webViewModel {
            if back {
                model.goBack()
            } else {
                model.goForward()
            }
        }
    }
    
    func navigateTabs(back: Bool = true) {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId), contentViewModel.tabs.count > 0 else { return }
        if let currentTab = contentViewModel.tabs.first(where: {$0.id == contentViewModel.currentTab}) {
            currentTab.webViewModel.removeHighlights()
        }
        contentViewModel.showInlineSearch = false
        if back {
            guard let _ = contentViewModel.currentTab, let index = contentViewModel.tabs.firstIndex(where: {$0.id == contentViewModel.currentTab}) else {
                contentViewModel.currentTab = contentViewModel.tabs[0].id
                return
            }
            contentViewModel.currentTab = contentViewModel.tabs[max(0, index - 1)].id
            return
        }
        guard let index = contentViewModel.tabs.firstIndex(where: {$0.id == contentViewModel.currentTab}) else {
            contentViewModel.currentTab = contentViewModel.tabs[contentViewModel.tabs.count - 1].id
            return
        }
        contentViewModel.currentTab = contentViewModel.tabs[min(contentViewModel.tabs.count - 1, index + 1)].id
    }
    
    func closeCurrentTab() {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId) else {
            return
        }
        contentViewModel.handleClose()
    }
    
    func tabSwitchingDisabled(back: Bool = true) -> Bool {
        let currentWindow = appViewModel.currentlyActiveWindowId
        guard let contentViewModel = contentViewModel(for: currentWindow) else { return true }
        let tabCount = contentViewModel.tabs.count
        return tabCount <= 0
    }
    
    func openTabHistory() {
        let currentWindow = appViewModel.currentlyActiveWindowId
        guard let contentViewModel = contentViewModel(for: currentWindow) else { return }
        contentViewModel.triggerRestoredHistory.toggle()
        print("shouldOpen")
    }
    
    func isTabHistoryDisabled()-> Bool {
        let currentWindow = appViewModel.currentlyActiveWindowId
        guard let contentViewModel = contentViewModel(for: currentWindow), let tab = contentViewModel.tabs.first(where: {$0.id == contentViewModel.currentTab}), !tab.restoredURLs.isEmpty else { return true }
        return false
    }
    
    func reload(fromSource: Bool = false) {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId) else { return }
        if let tab = contentViewModel.tabs.first(where: {$0.id == contentViewModel.currentTab}) {
            if !fromSource {
                tab.webViewModel.webView?.reload()
            } else {
                tab.webViewModel.webView?.reloadFromOrigin()
            }
        }
    }
    
    func reloadDisabled() -> Bool {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId) else { return true }
        return contentViewModel.tabs.isEmpty || contentViewModel.currentTab == nil || contentViewModel.tabs.first(where: {$0.id == contentViewModel.currentTab}) == nil
    }
    
    func onAppear() {
        appViewModel.modelContainer = container
        appViewModel.showMeiliSetup = !UDKey.wasMeiliSetupOnce.boolValue
        appDelegate.configure(appViewModel: appViewModel, contentViewModel: contentViewModel, contentViewModel2: contentViewModel2, contentViewModel3: contentViewModel3, container: container)
        appViewModel.openWindow = { url in
            openWindow(value: url)
        }
        do {
            appViewModel.meili = try MeiliSearch(host: "http://localhost:7700", apiKey: KeyChainManager.getValue(for: .meiliMasterKey))
        } catch {
            print(error)
        }
        
        appViewModel.openMiniInNewTab = { url, id, newTab in
            let vm = WebViewModel(processPool: contentViewModel.wkProcessPool, contentViewModel: contentViewModel, appViewModel: appViewModel)
            vm.load(urlString: url?.absoluteString ?? "")
            let tab = ATab(webViewModel: vm, restoredURLs: [])
            switch id {
            case "window1":
                contentViewModel.tabs.append(tab)
                if newTab {
                    contentViewModel.currentTab = tab.id
                }
                openWindow(id: "window1")
            case "window2":
                contentViewModel2.tabs.append(tab)
                if newTab {
                    contentViewModel2.currentTab = tab.id
                }
                openWindow(id: "window2")
            default:
                contentViewModel3.tabs.append(tab)
                if newTab {
                    contentViewModel3.currentTab = tab.id
                }
                openWindow(id: "window3")
            }
        }
        
        appViewModel.openWindowByID = { id in
            openWindow(id: id)
        }
    }
    
    func search() {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId) else { return }
        contentViewModel.showInlineSearch.toggle()
    }
    
    func showHistory() {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId) else { return }
        contentViewModel.showHistory.toggle()
    }
    
    func contentViewModel(for id: String) -> ContentViewModel? {
        switch id {
        case "window1":
            contentViewModel
        case "window2":
            contentViewModel2
        case "window3":
            contentViewModel3
        default:
            nil
        }
    }
    
    @SceneBuilder
    func createWindow(id: String, viewModel: ContentViewModel) -> some Scene {
        Window("Amethyst Browser", id: id) {
            ContentView()
                .frame(minWidth: 600, minHeight: 600)
                .ignoresSafeArea(.container, edges: .top)
                .modelContainer(container)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == id }) {
                            window.standardWindowButton(.closeButton)?.isHidden = true
                            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                            window.standardWindowButton(.zoomButton)?.isHidden = true
                            window.delegate = appViewModel
                        }
                    }
                    onAppear()
                }
                .environment(appViewModel)
                .environment(viewModel)
        }
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
        .windowStyle(.hiddenTitleBar)
        .defaultAppStorage(UserDefaults.standard)
    }
}
