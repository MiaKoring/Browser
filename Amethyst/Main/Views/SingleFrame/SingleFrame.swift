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
                    Button{
                        showWindowSelection.toggle()
                    } label: {
                        HStack(spacing: 0) {
                            Text("Open in Tab ")
                                .opacity(0.6)
                                .bold()
                            (Text(Image(systemName: "command")) + Text("T"))
                                .opacity(0.6)
                                .bold()
                                .padding(3)
                                .background {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(.regularMaterial)
                                }
                        }
                    }
                    .keyboardShortcut("t", modifiers: [.command])
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
                    MiniWebView(viewModel: webViewModel)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(10)
                }
            }
        }
        .onChange(of: webViewModel.currentURL) {
            url = webViewModel.currentURL
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .sheet(isPresented: $showWindowSelection) {
                ZStack {
                    HStack {
                        ForEach(appViewModel.displayedWindows.filter({$0.hasPrefix("window")}).sorted(), id: \.self) { window in
                            Button {
                                handleWindowOpening(selected: window)
                            } label: {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.myPurple.opacity(0.3))
                                    .frame(width: 200, height: 200)
                                    .overlay {
                                        ZStack {
                                            Text(window.description.replacingOccurrences(of: "window", with: ""))
                                                .allowsHitTesting(false)
                                        }
                                    }
                                    .onHover { hovering in
                                        if hovering {
                                            appViewModel.highlightedWindow = window
                                        } else {
                                            appViewModel.highlightedWindow = ""
                                        }
                                    }
                                    .contentShape(RoundedRectangle(cornerRadius: 5))
                            }
                            .buttonStyle(.plain)
                        }
                        if appViewModel.displayedWindows.count(where: {$0.hasPrefix("window")}) < 3 {
                            Button {
                                handleWindowOpening(selected: "newWindow")
                            } label: {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.myPurple.opacity(0.3))
                                    .frame(width: 200, height: 200)
                                    .overlay {
                                        ZStack {
                                            Image(systemName: "plus")
                                                .allowsHitTesting(false)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(10)
                .background() {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.thinMaterial)
                        .background(.myPurple.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
        }
    }
}

