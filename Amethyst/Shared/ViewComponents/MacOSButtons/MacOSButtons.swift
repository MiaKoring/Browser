//
//  MacOSButtons.swift
//  Amethyst
//
//  Created by Mia Koring on 28.11.24.
//
import SwiftUI

struct MacOSButtons: View {
    @State var isHovered: Bool = false
    var body: some View {
        HStack {
            if let window = NSApplication.shared.windows.first {
                Image(systemName: isHovered ? "xmark.circle.fill": "circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .onTapGesture {
                        window.performClose(nil)
                    }
                
                if !window.isZoomed {
                    Image(systemName: isHovered ? "minus.circle.fill": "circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                        .onTapGesture {
                            window.performMiniaturize(nil)
                        }
                } else {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.8))
                }
                
                Image(systemName: isHovered ? window.isZoomed ? "arrow.down.forward.and.arrow.up.backward.circle.fill" :"arrow.up.backward.and.arrow.down.forward.circle.fill": "circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.green)
                    .onTapGesture {
                        window.toggleFullScreen(nil)
                    }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
