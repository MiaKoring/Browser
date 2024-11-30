//
//  ContentViewModel.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//
import SwiftUI
import SwiftData
import WebKit

@Observable
class ContentViewModel: NSObject, ObservableObject {
    let id: String
    var triggerNewTab: Bool = false
    var isSidebarShown: Bool = false
    var isSidebarFixed: Bool = false
    var currentTab: UUID?
    var tabs: [ATab] = []
    var wkProcessPool = WKProcessPool()
    
    init(id: String) {
        self.id = id
    }
}
struct ContentView {
    @Environment(AppViewModel.self) var appViewModel: AppViewModel
    @Environment(ContentViewModel.self) var contentViewModel: ContentViewModel
    @Environment(\.modelContext) var context: ModelContext
    @Environment(\.dismissWindow) var dismissWindow
    @State var showInputBar: Bool = false
    @State var inputBarText: String = ""
    @State var sidebarWidth: CGFloat = 308
    @State var showMacosWindowIconsAreaHovered: Bool = false
    @State var macosWindowIconsHovered: Bool = false
}

