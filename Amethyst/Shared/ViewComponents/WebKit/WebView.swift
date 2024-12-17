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
            if let error = webViewModel.error {
                VStack {
                    HStack {
                        Text(error.localizedDescription)
                            .foregroundStyle(.black)
                            .padding()
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
