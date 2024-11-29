//
//  Untitled.swift
//  Amethyst
//
//  Created by Mia Koring on 28.11.24.
//

import SwiftUI
import WebKit

extension TabOpener {
    func handleInputBarSubmit(text: String, tabID: UUID? = nil) {
        do {
            if text == ":q" {
                try context.delete(model: SavedTab.self)
                if let window = NSApplication.shared.windows.first {
                    window.performClose(nil)
                }
                return
            } else if text == ":wq" {
                try context.delete(model: SavedTab.self)
                for i in 0..<appViewModel.tabs.count {
                    let tab = appViewModel.tabs[i]
                    context.insert(SavedTab(id: tab.id, sortingID: i, url: tab.webViewModel.currentURL))
                }
                if let window = NSApplication.shared.windows.first {
                    window.performClose(nil)
                }
                return
            }
        } catch {
            print("deletings models failed")
        }
        guard let _ = text.wholeMatch(of: Regexpr.url.regex) else {
            guard let _ = text.wholeMatch(of: Regexpr.urlWithoutProtocol.regex) else {
                let searchEngine = SearchEngine(rawValue: UDKey.searchEngine.intValue) ?? .duckduckgo
                let url = searchEngine.makeSearchUrl(text)
                let vm = WebViewModel(processPool: appViewModel.wkProcessPool)
                vm.load(urlString: url?.absoluteString ?? "")
                if let tabID {
                    guard let index = appViewModel.tabs.firstIndex(where: {$0.id == tabID}) else {
                        return
                    }
                    appViewModel.tabs[index].webViewModel.load(urlString: url?.absoluteString ?? "")
                } else {
                    let tab = ATab(webViewModel: vm)
                    appViewModel.tabs.append(tab)
                    appViewModel.currentTab = tab.id
                }
                return
            }
            let vm = WebViewModel(processPool: appViewModel.wkProcessPool)
            vm.load(urlString: "https://\(text)")
            if let tabID {
                guard let index = appViewModel.tabs.firstIndex(where: {$0.id == tabID}) else {
                    return
                }
                appViewModel.tabs[index].webViewModel.load(urlString: text)
            } else {
                let tab = ATab(webViewModel: vm)
                appViewModel.tabs.append(tab)
                appViewModel.currentTab = tab.id
            }
            return
        }
        let vm = WebViewModel(processPool: appViewModel.wkProcessPool)
        vm.load(urlString: text)
        if let tabID {
            guard let index = appViewModel.tabs.firstIndex(where: {$0.id == tabID}) else {
                return
            }
            appViewModel.tabs[index].webViewModel.load(urlString: text)
        } else {
            let tab = ATab(webViewModel: vm)
            appViewModel.tabs.append(tab)
            appViewModel.currentTab = tab.id
        }
    }
}
