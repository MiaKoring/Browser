//
//  URLDisplay.swift
//  Amethyst
//
//  Created by Mia Koring on 28.11.24.
//
import SwiftUI

extension URLDisplay: View, TabOpener {
    var body: some View {
        VStack {
            if !showTextField {
                HStack {
                    if let currentTab = appViewModel.tabs.first(where: {$0.id == appViewModel.currentTab}) {
                        Display(webViewModel: currentTab.webViewModel, url: $url)
                            .allowsHitTesting(false)
                    } else {
                        Text("Select Tab")
                            .allowsHitTesting(false)
                    }
                    Spacer()
                }
            } else {
                TextField("Search or URL", text: $text)
                    .focused($urlTextFieldFocused)
                    .textFieldStyle(.plain)
            }
        }
        .padding(10)
        .background() {
            RoundedRectangle(cornerRadius: 12)
                .fill(.thinMaterial)
                .background(.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onTapGesture {
                    if !showTextField {
                        text = url
                        showTextField = true
                        urlTextFieldFocused = true
                    }
                }
        }
        .foregroundStyle(.white.opacity(0.5))
        .onKeyPress(.escape) {
            showTextField = false
            return .handled
        }
        .onSubmit {
            if let currentTab = appViewModel.tabs.first(where: {$0.id == appViewModel.currentTab}) {
                handleInputBarSubmit(text: text, tabID: currentTab.id)
                showTextField = false
            } else {
                handleInputBarSubmit(text: text)
                showTextField = false
            }
        }
    }
    
    struct Display: View {
        @ObservedObject var webViewModel: WebViewModel
        @Binding var url: String
        var body: some View {
            VStack {
                if let currentUrl = webViewModel.currentURL {
                    Text(currentUrl.host() ?? "Loading...")
                } else {
                    Text("Loading...")
                }
            }
                .onChange(of: webViewModel.currentURL) {
                    if let new = webViewModel.currentURL {
                        url = new.absoluteString
                    }
                }
        }
    }
}

