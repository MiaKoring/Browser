//
//  ContentViewModel.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//
import SwiftUI

struct ContentView {
    @ObservedObject var webViewModel: WebViewModel
    @Environment(AppViewModel.self) var appViewModel
    @State var showInputBar: Bool = false
    @State var inputBarText: String = ""
    let webView: WebView
    
    init() {
        let webViewModel = WebViewModel()
        self.webViewModel = webViewModel
        self.webView = WebView(viewModel: webViewModel)
    }
    
    func handleInputBarSubmit() {
        guard let _ = inputBarText.wholeMatch(of: Regexpr.url.regex) else {
            let searchEngine = SearchEngine(rawValue: UDKey.searchEngine.intValue) ?? .duckduckgo
            let url = searchEngine.makeSearchUrl(inputBarText)
            webViewModel.load(urlString: url?.absoluteString ?? "")
            inputBarText = ""
            showInputBar = false
            return
        }
        webViewModel.load(urlString: inputBarText)
        inputBarText = ""
        showInputBar = false
    }
}

