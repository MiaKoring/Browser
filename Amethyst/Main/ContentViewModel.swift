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
    var blockNotification: Bool = false
    
    init(id: String) {
        self.id = id
    }
    
    func handleClose() {
        guard let index = tabs.firstIndex(where: {$0.id == currentTab}) else { return }
        if tabs.count > 1 {
            let before = tabs[max(0, index - 1)].id
            let after = tabs[min(tabs.count - 1, index + 1)].id
            currentTab = before == currentTab ? after : before
        } else {
            currentTab = nil
        }
        withAnimation(.linear(duration: 0.2)) {
            tabs[index].webViewModel.deinitialize()
            tabs.remove(at: index)
        }
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
    @State var window: NSWindow? = nil
    @Environment(\.scenePhase) var scenePhase
}

