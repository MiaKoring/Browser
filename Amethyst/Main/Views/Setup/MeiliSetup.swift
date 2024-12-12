//
//  MeiliSetup.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 06.12.24.
//

import SwiftUI

struct MeiliSetup: View {
    @State private var current: MeiliSetupStep = .whatIs
    @Environment(AppViewModel.self) var appViewModel
    @Environment(\.dismiss) var dismiss
    var body: some View {
        BackgroundView(shouldRotate: false) {
            VStack {
                ZStack {
                    ForEach(MeiliSetupStep.allCases) { step in
                        step.view()
                            .frame(width: 680, height: 380)
                            .if (step != current) { view in
                                view.hidden()
                            }
                    }
                    .overlay(alignment: .topTrailing) {
                        if current == .whatIs {
                            Button("Skip") {
                                appViewModel.shouldSkipMeiliNotification = true
                                dismiss()
                            }
                            .buttonStyle(.borderless)
                            .padding()
                        }
                    }
                    HStack {
                        if current != .whatIs {
                            Button {
                                current = current.previous
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.title)
                                    .padding(.leading, 5)
                            }
                            .buttonStyle(.borderless)
                        }
                        Spacer()
                        if current != .checkMeiliRunning {
                            Button {
                                current = current.next
                            } label: {
                                Image(systemName: "chevron.right")
                                    .font(.title)
                                    .padding(.trailing, 5)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
                .frame(height: 380)
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
