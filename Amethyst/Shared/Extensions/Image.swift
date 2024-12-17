//
//  Image.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 17.12.24.
//

import SwiftUI

extension Image {
    func sidebarTopButton(hovered: Binding<Bool>, onTap: @escaping () -> Void) -> some View {
        self
            .font(.title2)
            .foregroundStyle(.gray)
            .padding(3)
            .background() {
                if !hovered.wrappedValue {
                    Color.clear
                } else {
                    Color.white.opacity(0.1)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            .onHover { hovering in
                withAnimation(.linear(duration: 0.07)) {
                    hovered.wrappedValue = hovering
                }
            }
            .onTapGesture {
                onTap()
            }
    }
}
