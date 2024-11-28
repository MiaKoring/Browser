//
//  Untitled.swift
//  Amethyst
//
//  Created by Mia Koring on 28.11.24.
//
import SwiftUI

extension Sidebar: View {
    var body: some View {
        VStack {
            HStack {
                MacOSButtons()
                    .padding(.trailing)
                    .padding(.leading, 5)
                Image(systemName: "sidebar.left")
                    .font(.title2)
                    .foregroundStyle(.gray)
                    .padding(3)
                    .background() {
                        if !isSideBarButtonHovered {
                            Color.clear
                        } else {
                            Color.white.opacity(0.1)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .onHover { hovering in
                        withAnimation(.linear(duration: 0.07)) {
                            isSideBarButtonHovered = hovering
                        }
                    }
                    .onTapGesture {
                        appViewModel.isSidebarFixed.toggle()
                        appViewModel.isSidebarShown = false
                    }
                Spacer()
            }
            .padding(.leading, appViewModel.isSidebarFixed ? 5: 0)
            .padding(.top, appViewModel.isSidebarFixed ? 5: 0)
            URLDisplay()
                .padding(.top)
            Divider()
            ATabView()
        }
        .frame(maxHeight: .infinity)
        .frame(maxWidth: appViewModel.isSidebarFixed ? .infinity: 300)
        .padding(5)
        .background {
            HStack {
                if appViewModel.isSidebarFixed {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.ultraThinMaterial)
                } else {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.myPurple.mix(with: .white, by: 0.1))
                }
            }
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(lineWidth: 1)
                        .fill(.ultraThickMaterial)
                        .shadow(radius: 5)
                }
        }
        .padding(appViewModel.isSidebarFixed ? 0: 8)
    }
}

#Preview {
    @Previewable @State var appViewModel = AppViewModel()
    BackgroundView {
        ZStack {
            ContentView()
            HStack {
                Sidebar()
                
                Spacer()
            }
        }
    }
    .environment(appViewModel)
    .onAppear() {
        let vm = WebViewModel()
        vm.load(urlString: "https://miakoring.de")
        let tab = ATab(webViewModel: vm)
        appViewModel.tabs.append(tab)
        appViewModel.currentTab = tab.id
    }
}
