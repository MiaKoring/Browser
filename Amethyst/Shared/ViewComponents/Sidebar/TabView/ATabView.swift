
import SwiftUI

extension ATabView: View {
    var body: some View {
        VStack {
            ForEach(appViewModel.tabs, id: \.id) { tab in
                TabButton(id: tab.id, tabVM: tab.webViewModel)
            }
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
                let vm = WebViewModel()
                vm.load(urlString: "https://google.com")
                appViewModel.tabs.append(ATab(webViewModel: vm))
                let vm1 = WebViewModel()
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
            } else {
                Text(tabVM.currentURL?.absoluteString ?? "failed")
            }
            Spacer()
        }
        .padding(10)
        .overlay {
            if isHovered {
                HStack {
                    Spacer()
                    Button {
                        let index = appViewModel.tabs.firstIndex(where: {$0.id == id}) ?? 0
                        if appViewModel.tabs.count > 1 {
                            appViewModel.currentTab = appViewModel.tabs[max(0, index - 1)].id
                        } else {
                            appViewModel.currentTab = nil
                        }
                        withAnimation(.linear(duration: 0.2)) {
                            appViewModel.tabs.removeAll(where: {$0.id == id})
                        }
                    } label: {
                        Image(systemName: "xmark.square.fill")
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
