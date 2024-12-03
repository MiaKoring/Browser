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
    
    func handleWindowOpening(selected: String) {
        guard let open = appViewModel.openMiniInNewTab else { return }
        if selected == "newWindow" {
            let window = ["window1", "window2", "window3"].first(where: {!appViewModel.displayedWindows.contains($0)}) ?? "window1"
            open(webViewModel.currentURL, window, true)
            showWindowSelection = false
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                dismissWindow()
            }
        } else {
            open(webViewModel.currentURL, selected, true)
            showWindowSelection = false
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                dismissWindow()
            }
        }
    }
}
