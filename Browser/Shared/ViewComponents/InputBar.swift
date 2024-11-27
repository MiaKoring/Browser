//
//  InputBar.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//

import SwiftUI

struct InputBar: View {
    @Binding var text: String
    @Binding var showInputBar: Bool
    @FocusState var inputFocused: Bool
    let onSubmit: () -> Void
    var body: some View {
        TextField("Search or enter URL", text: $text)
            .textFieldStyle(.plain)
            .font(.title)
            .focused($inputFocused)
            .padding()
            .background() {
                RoundedRectangle(cornerRadius: 15)
                    .fill(.myPurple.opacity(0.5))
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .onSubmit {
                onSubmit()
            }
            .onKeyPress(.escape) {
                showInputBar = false
                return .handled
            }
            .onAppear() {
                inputFocused = true
            }
    }
}

#Preview {
    @Previewable @State var text: String = ""
    VStack {
        Spacer()
        HStack {
            Spacer()
            InputBar(text: $text, showInputBar: .constant(true)) {}
            Spacer()
        }
        Spacer()
    }
    .frame(maxWidth: 1000)
}
