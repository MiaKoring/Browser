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
                    if showWindowSelection {
                        HStack(spacing: 0) {
                            Text("Confirm")
                            Button {
                                handleWindowOpening(selected: selectedWindowOption)
                            } label: {
                                HStack {
                                    (Text(Image(systemName: "command")) + Text(Image(systemName: "return")))
                                        .opacity(0.6)
                                        .bold()
                                        .padding(3)
                                        .background {
                                            RoundedRectangle(cornerRadius: 3)
                                                .fill(.regularMaterial)
                                        }
                                }
                            }
                            .keyboardShortcut(.return, modifiers: .command)
                            .buttonStyle(.plain)
                            .padding(.trailing, 10)
                            Text("Change Selection")
                            Button {
                                highlightSelection()
                            } label: {
                                HStack {
                                    (Text(Image(systemName: "command")) + Text("A"))
                                        .opacity(0.6)
                                        .bold()
                                        .padding(3)
                                        .background {
                                            RoundedRectangle(cornerRadius: 3)
                                                .fill(.regularMaterial)
                                        }
                                }
                            }
                            .keyboardShortcut("a", modifiers: .command)
                            .buttonStyle(.plain)
                            Text("/")
                            Button {
                                highlightSelection(left: false)
                            } label: {
                                HStack {
                                    (Text(Image(systemName: "command")) + Text("D"))
                                        .opacity(0.6)
                                        .bold()
                                        .padding(3)
                                        .background {
                                            RoundedRectangle(cornerRadius: 3)
                                                .fill(.regularMaterial)
                                        }
                                }
                            }
                            .keyboardShortcut("d", modifiers: .command)
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 10)
                    }
                    Button{
                        showWindowSelection.toggle()
                        selectedWindowOption = windowSelectOptions().first ?? ""
                        print(appViewModel.displayedWindows)
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
                    if showWindowSelection {
                        ZStack {
                            HStack {
                                ForEach(appViewModel.displayedWindows.filter({$0.hasPrefix("window")}).sorted(), id: \.self) { window in
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.myPurple.opacity(0.3))
                                        .frame(width: 200, height: 200)
                                        .overlay {
                                            ZStack {
                                                if selectedWindowOption == window {
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(lineWidth: 5)
                                                        .foregroundStyle(.white)
                                                }
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
                                        .onTapGesture {
                                            handleWindowOpening(selected: window)
                                        }
                                    
                                }
                                if appViewModel.displayedWindows.count(where: {$0.hasPrefix("window")}) < 3 {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.myPurple.opacity(0.3))
                                        .frame(width: 200, height: 200)
                                        .overlay {
                                            ZStack {
                                                if selectedWindowOption == "newWindow" {
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(lineWidth: 5)
                                                        .foregroundStyle(.white)
                                                }
                                                Image(systemName: "plus")
                                                    .allowsHitTesting(false)
                                            }
                                        }
                                        .onTapGesture {
                                            handleWindowOpening(selected: "newWindow")
                                        }
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

