//
//  DownloadButtonView.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 09.02.25.
//

import SwiftUI

extension DownloadOverviewButton: View {
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "arrow.down.app")
                .font(.title)
                .foregroundStyle(.gray.mix(with: .white, by: 0.3))
                .padding(5)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(-2)
                .overlay(alignment: .topTrailing) {
                    if !appViewModel.downloadManager.activeDownloads.isEmpty {
                        Circle()
                            .fill(.blue)
                            .frame(width: 8)
                            .offset(x: -3, y: 3)
                    }
                }
                .onHover { isHovered in
                    if isHovered {
                        playAnimation.toggle()
                    }
                }
                .symbolEffect(.wiggle.byLayer, value: playAnimation)
        }
    }
}
