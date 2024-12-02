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
                dismissWindow()
                return
            } else if text == ":clear" {
                contentViewModel.tabs = []
                contentViewModel.currentTab = nil
                return
            }
        } catch {
            print("deletings models failed")
        }
        guard let regex = Regexpr.url.regex, let _ = text.wholeMatch(of: regex) else {
            guard let regex = Regexpr.urlWithoutProtocol.regex, let _ = text.wholeMatch(of: regex) else {
                let searchEngine = SearchEngine(rawValue: UDKey.searchEngine.intValue) ?? .duckduckgo
                let url = searchEngine.makeSearchUrl(text)
                let vm = WebViewModel(processPool: contentViewModel.wkProcessPool, contentViewModel: contentViewModel, appViewModel: appViewModel)
                vm.load(urlString: url?.absoluteString ?? "")
                if let tabID {
                    guard let index = contentViewModel.tabs.firstIndex(where: {$0.id == tabID}) else {
                        return
                    }
                    contentViewModel.tabs[index].webViewModel.load(urlString: url?.absoluteString ?? "")
                } else {
                    let tab = ATab(webViewModel: vm, restoredURLs: [])
                    contentViewModel.tabs.append(tab)
                    contentViewModel.currentTab = tab.id
                }
                return
            }
            let vm = WebViewModel(processPool: contentViewModel.wkProcessPool, contentViewModel: contentViewModel, appViewModel: appViewModel)
            vm.load(urlString: "https://\(text)")
            if let tabID {
                guard let index = contentViewModel.tabs.firstIndex(where: {$0.id == tabID}) else {
                    return
                }
                contentViewModel.tabs[index].webViewModel.load(urlString: text)
            } else {
                let tab = ATab(webViewModel: vm, restoredURLs: [])
                contentViewModel.tabs.append(tab)
                contentViewModel.currentTab = tab.id
            }
            return
        }
        let vm = WebViewModel(processPool: contentViewModel.wkProcessPool, contentViewModel: contentViewModel, appViewModel: appViewModel)
        vm.load(urlString: text)
        if let tabID {
            guard let index = contentViewModel.tabs.firstIndex(where: {$0.id == tabID}) else {
                return
            }
            contentViewModel.tabs[index].webViewModel.load(urlString: text)
        } else {
            let tab = ATab(webViewModel: vm, restoredURLs: [])
            contentViewModel.tabs.append(tab)
            contentViewModel.currentTab = tab.id
        }
    }
}
