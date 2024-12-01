//
//  ContentView.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//
import Combine
import SwiftData
import SwiftUI
import WebKit


extension ContentView: View, TabOpener {
    
    var body: some View {
        GeometryReader { reader in
            BackgroundView {
                ZStack {
                    HostingWindowFinder(callback: { window in
                        if let window {
                            if let id = window.identifier {
                                self.appViewModel.currentlyActiveWindowId = id.rawValue
                                self.appViewModel.displayedWindows.insert(id.rawValue)
                                self.window = window
                            }
                        }
                    })
                    if appViewModel.highlightedWindow == contentViewModel.id {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 5)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    VStack {
                        HStack {
                            Rectangle()
                                .fill(.clear)
                                .frame(width: 20, height: 20)
                                .contentShape(Rectangle())
                                .onHover { hovering in
                                    showMacosWindowIconsAreaHovered = hovering
                                }
                            Spacer()
                        }
                        Spacer()
                    }
                    HStack(spacing: -1) {
                        if contentViewModel.isSidebarFixed {
                            HStack {
                                Sidebar()
                                    .frame(maxWidth: sidebarWidth)
                                    .overlay(alignment: .trailing) {
                                        Rectangle()
                                            .fill(.clear)
                                            .frame(width: 10)
                                            .frame(maxHeight: .infinity)
                                            .contentShape(Rectangle())
                                            .gesture(
                                                DragGesture(minimumDistance: 10)
                                                    .onChanged { value in
                                                        NSCursor.frameResize(position: .right, directions: .all).set()
                                                        let changed = value.startLocation.x - value.location.x
                                                        sidebarWidth = max(200, min(sidebarWidth - changed, 400))
                                                    }
                                                    .onEnded { _ in
                                                        NSCursor.arrow.set()
                                                    }
                                            )
                                            .onHover { hovering in
                                                if hovering {
                                                    NSCursor.frameResize(position: .right, directions: .all).set()
                                                } else {
                                                    NSCursor.arrow.set()
                                                }
                                            }
                                            .offset(x: 10)
                                    }
                                if contentViewModel.tabs.isEmpty {
                                    Spacer()
                                }
                            }
                        }
                        ZStack {
                            ForEach(contentViewModel.tabs, id: \.self) { tab in
                                WebView(viewModel: tab.webViewModel)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .padding(10)
                                    .opacity(tab.id == contentViewModel.currentTab ? 1 : 0)
                            }
                        }
                    }
                    HStack {
                        if contentViewModel.isSidebarShown && !contentViewModel.isSidebarFixed {
                            Sidebar()
                                .transition(.move(edge: .leading))
                        }
                        Spacer()
                    }
                    if (showMacosWindowIconsAreaHovered || macosWindowIconsHovered) && !contentViewModel.isSidebarShown && !contentViewModel.isSidebarFixed {
                        
                        VStack {
                            HStack {
                                MacOSButtons()
                                    .padding(10)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(.regularMaterial)
                                            .background(Color.myPurple.opacity(0.2))
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    .onHover { hovering in
                                        macosWindowIconsHovered = hovering
                                    }
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }
            }
            .overlay {
                if showInputBar {
                    InputBar(text: $inputBarText, showInputBar: $showInputBar) {
                        handleInputBarSubmit(text: inputBarText)
                        inputBarText = ""
                        showInputBar = false
                    }
                    .frame(maxWidth: max(550, min(reader.size.width / 2, 800)))
                }
            }
            .onChange(of: contentViewModel.triggerNewTab) {
                showInputBar = true
            }
            .onChange(of: contentViewModel.tabs) {
                if contentViewModel.tabs.isEmpty {
                    contentViewModel.isSidebarShown = true
                }
            }
            .onAppear() {
                NotificationCenter.default.addObserver(
                    forName: NSWindow.didBecomeMainNotification,
                    object: nil,
                    queue: .main
                ) { notification in
                    if contentViewModel.blockNotification { // to block reinserting the window on close
                        contentViewModel.blockNotification = false
                        return
                    }
                    if let name = window?.identifier?.rawValue {
                        appViewModel.displayedWindows.insert(name)
                    }
                }
                if contentViewModel.tabs.isEmpty {
                    contentViewModel.isSidebarShown = true
                }
                let id = contentViewModel.id
                let fetchDescriptor = FetchDescriptor(predicate: #Predicate<SavedTab>{ return $0.windowID == id}, sortBy: [SortDescriptor(\SavedTab.sortingID, order: .forward)])
                do {
                    let savedTabs = try context.fetch(fetchDescriptor)
                    for savedTab in savedTabs {
                        let vm = WebViewModel(processPool: contentViewModel.wkProcessPool, restore: savedTab, contentViewModel: contentViewModel, appViewModel: appViewModel)
                        contentViewModel.tabs.append(ATab(id: savedTab.id, webViewModel: vm))
                    }
                } catch {
                    print("failed to fetch saved tabs")
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(
                self,
                name: NSWindow.didBecomeMainNotification,
                object: nil
            )
        }
        .environment(contentViewModel)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
}


#Preview {
    ContentView()
        .environment(AppViewModel())
}

