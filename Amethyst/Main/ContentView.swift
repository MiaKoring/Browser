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
                    HStack(spacing: -1) {
                        if appViewModel.isSidebarFixed {
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
                                if appViewModel.tabs.isEmpty {
                                    Spacer()
                                }
                            }
                        }
                        ZStack {
                            ForEach(appViewModel.tabs, id: \.self) { tab in
                                WebView(viewModel: tab.webViewModel)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .padding(10)
                                    .opacity(tab.id == appViewModel.currentTab ? 1 : 0)
                            }
                        }
                    }
                    HStack {
                        if appViewModel.isSidebarShown && !appViewModel.isSidebarFixed {
                            Sidebar()
                                .transition(.move(edge: .leading))
                        }
                        Spacer()
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
            .onChange(of: appViewModel.triggerNewTab) {
                showInputBar = true
            }
            .onChange(of: appViewModel.tabs) {
                if appViewModel.tabs.isEmpty {
                    appViewModel.isSidebarShown = true
                }
            }
            .onAppear() {
                if appViewModel.tabs.isEmpty {
                    appViewModel.isSidebarShown = true
                }
                let fetchDescriptor = FetchDescriptor<SavedTab>(predicate: #Predicate<SavedTab>{ tab in
                    return true
                }, sortBy: [SortDescriptor(\SavedTab.sortingID, order: .forward)])
                do {
                    let savedTabs = try context.fetch(fetchDescriptor)
                    for savedTab in savedTabs {
                        let vm = WebViewModel(processPool: appViewModel.wkProcessPool, restore: savedTab)
                        appViewModel.tabs.append(ATab(id: savedTab.id, webViewModel: vm))
                    }
                } catch {
                    print("failed to fetch saved tabs")
                }
            }
        }
    }
    
}


#Preview {
    ContentView()
        .environment(AppViewModel())
}

