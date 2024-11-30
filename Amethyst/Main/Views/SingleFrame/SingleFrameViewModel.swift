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
    @State var showMacosWindowIconsAreaHovered: Bool = false
    @State var macosWindowIconsHovered: Bool = false
    @Binding var url: URL?
    @State var showTabSelection: Bool = false
    
    init(appViewModel: AppViewModel, url: Binding<URL?>) {
        let webViewModel = MiniWebViewModel(appViewModel: appViewModel)
        webViewModel.load(urlString: url.wrappedValue?.absoluteString ?? (SearchEngine(rawValue: UDKey.searchEngine.intValue) ?? .duckduckgo).root)
        self.webViewModel = webViewModel
        self._url = url
    }
}
