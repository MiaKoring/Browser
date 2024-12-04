//
//  DetailView.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 04.12.24.
//
import SwiftUI

struct DetailView<Content: View>: View {
    let title: Text
    let content: Content
    @State var isExpanded: Bool
    
    init(title: Text, isExpanded: Bool = false, @ViewBuilder content: () -> Content) {
        self.title = title
        self.isExpanded = isExpanded
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    title
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .hidden()
                if isExpanded {
                    content
                        .transition(.scale)
                }
            }
            VStack {
                HStack {
                    title
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(isExpanded ? .degrees(90): .degrees(0))
                }
                .padding()
                .background() {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.ultraThinMaterial)
                        .background() {
                            Color.white.opacity(0.1)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                }
                .onTapGesture {
                    withAnimation(.linear(duration: 0.15)) {
                        isExpanded.toggle()
                    }
                }
                if isExpanded {
                    content
                        .hidden()
                }
            }
        }
        
    }
}
