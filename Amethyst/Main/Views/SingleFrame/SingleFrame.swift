//
//  SingleFrame.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 30.11.24.
//

import SwiftUI
import WebKit

extension SingleFrame: View {
    var body: some View {
        BackgroundView {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("open in tab"){
                        showTabSelection = true
                    }
                        .buttonStyle(.plain)
                        .padding(10)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.thinMaterial)
                                .background(.gray.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
                }
                ZStack {
                    HostingWindowFinder { window in
                        if let window {
                            if let id = window.identifier {
                                self.appViewModel.currentlyActiveWindowId = id.rawValue
                                self.appViewModel.displayedWindows.insert(id.rawValue)
                                print(id.rawValue)
                            }
                        }
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
                    MiniWebView(viewModel: webViewModel)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(10)
                    if showMacosWindowIconsAreaHovered || macosWindowIconsHovered {
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
                    if showTabSelection {
                        HStack {
                            ForEach(appViewModel.displayedWindows.filter({$0.hasPrefix("window")}).sorted(), id: \.self) { window in
                                RoundedRectangle(cornerRadius: 20)
                                    .background() {
                                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                                            .fill(.thinMaterial)
                                            .background(.myPurple.opacity(0.3))
                                            .clipShape(RoundedRectangle(cornerRadius: 25))
                                    }
                                    .frame(width: 200, height: 200)
                                    .overlay {
                                        Text(window.description.replacingOccurrences(of: "window", with: ""))
                                            .allowsHitTesting(false)
                                    }
                                    .onHover { hovering in
                                        if hovering {
                                            appViewModel.highlightedWindow = window
                                        } else {
                                            appViewModel.highlightedWindow = ""
                                        }
                                    }
                                    .onTapGesture {
                                        guard let open = appViewModel.openMiniInNewTab else { return }
                                        open(webViewModel.currentURL, window, true)
                                        dismissWindow()
                                    }
                                    
                            }
                        }
                        .padding(10)
                        .background() {
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .fill(.thinMaterial)
                                .background(.myPurple.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                        }
                    }
                }
            }
        }
        .onChange(of: webViewModel.currentURL) {
            url = webViewModel.currentURL
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

