//
//  ContentView.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//

import SwiftUI
import WebKit
import Combine

extension ContentView: View {
    var body: some View {
        GeometryReader { reader in
            BackgroundView {
                webView
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .padding(10)
                    .onAppear() {
                        webViewModel.load(urlString: "https://www.google.com/?client=safari")
                    }
            }
            .overlay {
                if showInputBar {
                    InputBar(text: $inputBarText, showInputBar: $showInputBar, onSubmit: handleInputBarSubmit)
                    .frame(maxWidth: max(550, min(reader.size.width / 2, 800)))
                }
            }
            .onChange(of: appViewModel.triggerNewTab) {
                showInputBar = true
            }
        }
    }
    
}


#Preview {
    ContentView()
        .environment(AppViewModel())
}

