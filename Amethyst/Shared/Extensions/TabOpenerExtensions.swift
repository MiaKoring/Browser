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
        guard let _ = text.wholeMatch(of: Regexpr.url.regex) else {
            let searchEngine = SearchEngine(rawValue: UDKey.searchEngine.intValue) ?? .duckduckgo
            let url = searchEngine.makeSearchUrl(text)
            let vm = WebViewModel()
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
        let vm = WebViewModel()
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
