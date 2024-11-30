//
//  AppDelegate.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 30.11.24.
//
import SwiftData
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var appViewModel: AppViewModel?
    var contentViewModel: ContentViewModel?
    var contentViewModel2: ContentViewModel?
    var contentViewModel3: ContentViewModel?
    var container: ModelContainer?
    
    func configure(appViewModel: AppViewModel, contentViewModel: ContentViewModel, contentViewModel2: ContentViewModel, contentViewModel3: ContentViewModel, container: ModelContainer) {
        self.appViewModel = appViewModel
        self.contentViewModel = contentViewModel
        self.contentViewModel2 = contentViewModel2
        self.contentViewModel3 = contentViewModel3
        self.container = container
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        print("willTerminate")
        guard let container else { return .terminateNow }
        let context = ModelContext(container)
        do {
            if let appViewModel {
                try context.delete(model: SavedTab.self)
                print(appViewModel.displayedWindows)
                if appViewModel.displayedWindows.contains("window1") {
                    if let contentViewModel {
                        insertTo(context: context, valuesOf: contentViewModel, id: "window1")
                    }
                }
                if appViewModel.displayedWindows.contains("window2") {
                    if let contentViewModel2 {
                        insertTo(context: context, valuesOf: contentViewModel2, id: "window2")
                    }
                }
                if appViewModel.displayedWindows.contains("window3") {
                    if let contentViewModel3 {
                        insertTo(context: context, valuesOf: contentViewModel3, id: "window3")
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        return .terminateNow
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("applicationLaunched")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            guard let container = self.container else { return }
            print("containerExists")
            let context = ModelContext(container)
            
            do {
                let window1Count = try context.fetchCount(FetchDescriptor<SavedTab>(predicate: #Predicate<SavedTab> { tab in
                    tab.windowID == "window1"
                }))
                let window2Count = try context.fetchCount(FetchDescriptor<SavedTab>(predicate: #Predicate<SavedTab> { tab in
                    tab.windowID == "window2"
                }))
                let window3Count = try context.fetchCount(FetchDescriptor<SavedTab>(predicate: #Predicate<SavedTab> { tab in
                    tab.windowID == "window3"
                }))
                if let appViewModel = self.appViewModel, let open = appViewModel.openWindowByID {
                    if window1Count > 0 {
                        open("window1")
                    }
                    if window2Count > 0 {
                        open("window2")
                    }
                    if window3Count > 0 {
                        open("window3")
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func insertTo(context: ModelContext, valuesOf values: ContentViewModel, id: String) {
        for i in 0..<values.tabs.count {
            let tab = values.tabs[i]
            let newTab = SavedTab(id: tab.id, sortingID: i, url: tab.webViewModel.currentURL, windowID: id)
            context.insert(newTab)
        }
    }
}

