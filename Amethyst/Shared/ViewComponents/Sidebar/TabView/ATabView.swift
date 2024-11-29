
import SwiftUI

extension ATabView: View {
    var body: some View {
        VStack {
            List(appViewModel.tabs) { tab in
                TabButton(id: tab.id, tabVM: tab.webViewModel)
                    .listRowSeparator(.hidden)
            }
            .scrollContentBackground(.hidden)
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
}


#Preview {
    @Previewable @State var appViewModel = AppViewModel()
    ZStack {
        ContentView()
            .environment(appViewModel)
            .onAppear() {
                let vm = WebViewModel(processPool: appViewModel.wkProcessPool, appViewModel: appViewModel)
                vm.load(urlString: "https://google.com")
                appViewModel.tabs.append(ATab(webViewModel: vm))
                let vm1 = WebViewModel(processPool: appViewModel.wkProcessPool, appViewModel: appViewModel)
                vm.load(urlString: "https://miakoring.de")
                appViewModel.tabs.append(ATab(webViewModel: vm1))
                appViewModel.currentTab = appViewModel.tabs.first!.id
            }
        HStack {
            ATabView()
                .environment(appViewModel)
            Spacer()
        }
    }
    
}

struct TabButton: View {
    let id: UUID
    @ObservedObject var tabVM: WebViewModel
    @State var isHovered: Bool = false
    @Environment(AppViewModel.self) var appViewModel
    var body: some View {
        HStack {
            if let title = tabVM.title, !title.isEmpty {
                Text(title)
                    .lineLimit(1)
            } else {
                Text(tabVM.currentURL?.absoluteString ?? "failed")
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(10)
        .overlay {
            HStack(spacing: 0) {
                Spacer()
                HStack {
                    if tabVM.isUsingCamera == .active {
                        Image(systemName: "camera.circle.fill")
                            .padding(5)
                            .background {
                                Circle()
                                    .fill(.ultraThinMaterial)
                            }
                    }
                    if tabVM.isUsingCamera == .muted {
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.camera.fill")
                            .padding(5)
                            .background {
                                Circle()
                                    .fill(.ultraThinMaterial)
                            }
                    }
                    if tabVM.isUsingMicrophone == .active {
                        Image(systemName: "microphone.circle.fill")
                            .padding(5)
                            .background {
                                Circle()
                                    .fill(.ultraThinMaterial)
                            }
                    }
                    if tabVM.isUsingMicrophone == .muted {
                        Image(systemName: "microphone.slash.circle.fill")
                            .padding(5)
                            .background {
                                Circle()
                                    .fill(.ultraThinMaterial)
                            }
                    }
                }
                .font(.title2)
                .foregroundStyle(.gray)
                .padding(.trailing, 5)
                if isHovered {
                    Button {
                        if appViewModel.currentTab == id {
                            let index = appViewModel.tabs.firstIndex(where: {$0.id == id}) ?? 0
                            if appViewModel.tabs.count > 1 {
                                let before = appViewModel.tabs[max(0, index - 1)].id
                                let after = appViewModel.tabs[min(appViewModel.tabs.count - 1, index + 1)].id
                                appViewModel.currentTab = before == id ? after : before
                            } else {
                                appViewModel.currentTab = nil
                            }
                        }
                        withAnimation(.linear(duration: 0.2)) {
                            appViewModel.tabs.first(where: {$0.id == id})?.webViewModel.deinitialize()
                            appViewModel.tabs.removeAll(where: {$0.id == id})
                        }
                    } label: {
                        Image(systemName: "xmark.square.fill")
                            .font(.title2)
                            .foregroundStyle(.gray)
                    }
                    .buttonStyle(.plain)
                    .padding(5)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background() {
            if appViewModel.currentTab == id {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.2))
            } else {
                if isHovered {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.1))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.thinMaterial)
                }
            }
        }
        .onHover { hovering in
            withAnimation(.linear(duration: 0.07)) {
                isHovered = hovering
            }
        }
        .onTapGesture {
            appViewModel.currentTab = id
        }
    }
}
