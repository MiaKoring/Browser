//
//  WebView.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 17.12.24.
//
import SwiftUI

struct WebView: View {
    let tabID: UUID
    @ObservedObject var webViewModel: WebViewModel
    @Environment(ContentViewModel.self) var contentViewModel
    var body: some View {
        ZStack {
            WebViewNS(viewModel: webViewModel)
                .if(tabID == contentViewModel.currentTab) { view in
                    view
                        .overlay(alignment: .bottomTrailing) {
                            DownloadButton(webViewModel: webViewModel)
                        }
                }
                .if(webViewModel.error != nil) { view in
                    view.allowsHitTesting(false)
                }
            if let error = webViewModel.error {
                VStack {
                    HStack {
                        VStack {
                            Text(error.localizedDescription)
                                .foregroundStyle(.black)
                                .padding()
                                .contextMenu {
                                    Button("Copy") {
                                        NSPasteboard.general.setString(error.localizedDescription, forType: .string)
                                    }
                                }
                            Button {
                                webViewModel.error = nil
                            } label: {
                                Text("Ignore Error for now")
                                    .foregroundStyle(.blue)
                            }
                            Button {
                                ErrorIgnoreManager.addIgnoredURLError(error)
                                webViewModel.error = nil
                            } label: {
                                Text("Ignore Error in the future")
                                    .foregroundStyle(.blue)
                            }
                            .buttonStyle(.plain)
                            .buttonRepeatBehavior(.disabled)
                            Text("It still will be logged, but won't interrupt you anymore through displaying fullscreen\nYou can edit ignored Errors in Settings")
                                .font(.footnote)
                                .foregroundStyle(.gray.mix(with: .black, by: 0.2))
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .background(.white)
            }
        }
        .if(tabID != contentViewModel.currentTab) { view in
            view
                .hidden()
        }
        .opacity(tabID == contentViewModel.currentTab ? 1 : 0)
        .allowsHitTesting(tabID == contentViewModel.currentTab)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .padding(10)
    }
}
