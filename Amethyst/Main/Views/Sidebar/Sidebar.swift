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
                        contentViewModel.isSidebarFixed.toggle()
                        contentViewModel.isSidebarShown = false
                    }
                Spacer()
            }
            .padding(.leading, contentViewModel.isSidebarFixed ? 5: 0)
            .padding(.top, contentViewModel.isSidebarFixed ? 5: 0)
            URLDisplay()
                .padding(.top)
            HStack{
                VStack {
                    Divider()
                }
                Button {
                    contentViewModel.tabs = []
                } label: {
                    Text("clear")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
                .buttonStyle(.plain)
            }
            HStack {
                Image(systemName: "plus")
                Text("New Tab")
                Spacer()
            }
            .allowsHitTesting(false)
            .frame(maxWidth: .infinity)
            .padding(10)
            .background {
                HStack {
                    if isNewTabHovered {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white.opacity(0.1))
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                        
                    }
                }
                .onTapGesture {
                    contentViewModel.triggerNewTab.toggle()
                }
                .onHover { hovering in
                    isNewTabHovered = hovering
                }
            }
            
            ATabView()
                .padding(-15)
        }
        .frame(maxHeight: .infinity)
        .frame(maxWidth: contentViewModel.isSidebarFixed ? .infinity: 300)
        .padding(5)
        .background {
            HStack {
                if contentViewModel.isSidebarFixed {
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
        .padding(contentViewModel.isSidebarFixed ? 0: 8)
    }
}

#Preview {
    @Previewable @State var contentViewModel = ContentViewModel(id: "lol")
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
    .environment(contentViewModel)
    .environment(appViewModel)
    .onAppear() {
        let vm = WebViewModel(processPool: contentViewModel.wkProcessPool, contentViewModel: contentViewModel, appViewModel: appViewModel)
        vm.load(urlString: "https://miakoring.de")
        let tab = ATab(webViewModel: vm)
        contentViewModel.tabs.append(tab)
        contentViewModel.currentTab = tab.id
    }
}
