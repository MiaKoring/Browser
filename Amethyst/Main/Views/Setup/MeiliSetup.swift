//
//  MeiliSetup.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 06.12.24.
//

import SwiftUI

struct MeiliSetup: View {
    @State private var currentPage: ScrollPosition = .init(id: 0)
    var body: some View {
        BackgroundView(shouldRotate: false) {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            ForEach(MeiliSetupStep.allCases) { step in
                                step.view()
                                    .scrollTargetLayout()
                                    .frame(width: 680, height: 380)
                                    .id(step.rawValue)
                                    .overlay(alignment: .bottomTrailing) {
                                        if step != .checkMeiliRunning {
                                            Image(systemName: "chevron.right")
                                                .padding(10)
                                        }
                                    }
                            }
                        }
                    }
                }
                .frame(height: 380)
                .scrollTargetBehavior(.paging)
            }
            .background() {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.thinMaterial)
            }
            .padding(10)
        }
    }
}

#Preview {
    MeiliSetup()
        .frame(width: 700, height: 400)
}
