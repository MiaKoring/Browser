//
//  SingleFrameVIewModel.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 30.11.24.
//

import SwiftUI
import WebKit

struct SingleFrame {
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(AppViewModel.self) var appViewModel
    @State var webViewModel: MiniWebViewModel
    @Binding var url: URL?
    @State var showWindowSelection: Bool = false
    @State var selectedWindowOption: String = ""
    
    init(appViewModel: AppViewModel, url: Binding<URL?>) {
        let webViewModel = MiniWebViewModel(appViewModel: appViewModel)
        webViewModel.load(urlString: url.wrappedValue?.absoluteString ?? (SearchEngine(rawValue: UDKey.searchEngine.intValue) ?? .duckduckgo).root)
        self.webViewModel = webViewModel
        self._url = url
    }
    
    func windowSelectOptions() -> [String] {
        var options = appViewModel.displayedWindows.filter({$0.hasPrefix("window")}).sorted()
        if options.count < 3 {
            options.append("newWindow")
        }
        return options
    }
    
    func highlightSelection(left: Bool = true) {
        let options = windowSelectOptions()
        let currentIndex = options.firstIndex(of: selectedWindowOption) ?? 0
        if left {
            let index = currentIndex - 1 >= 0 ? currentIndex - 1: options.count - 1
            selectedWindowOption = options[index]
        } else {
            let index = currentIndex + 1 < options.count ? currentIndex + 1: 0
            selectedWindowOption = options[index]
        }
    }
    
    func handleWindowOpening(selected: String) {
        guard let open = appViewModel.openMiniInNewTab else { return }
        if selected == "newWindow" {
            let window = ["window1", "window2", "window3"].first(where: {!appViewModel.displayedWindows.contains($0)}) ?? "window1"
            open(webViewModel.currentURL, window, true)
            dismissWindow()
        } else {
            open(webViewModel.currentURL, selected, true)
            dismissWindow()
        }
    }
}
