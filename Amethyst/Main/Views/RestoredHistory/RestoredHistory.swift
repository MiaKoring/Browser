//
//  RestoredHistory.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 01.12.24.
//

import SwiftUI
import SwiftData

struct RestoredHistory: View {
    @Environment(ContentViewModel.self) var contentViewModel
    @State var selected: UUID? = nil
    @Environment(\.dismiss) var dismiss
    var body: some View {
        BackgroundView(shouldRotate: false) {
            VStack(spacing: 0) {
                HStack {
                    Text("Confirm")
                    Button {
                        if let tab = contentViewModel.tabFor(id: contentViewModel.currentTab),
                           let selectedUrl = tab.restoredURLs.first(where: {$0.id == selected}),
                           let urlString = selectedUrl.url?.absoluteString {
                            tab.webViewModel.load(urlString: urlString)
                            dismiss()
                        }
                    } label: {
                        HStack {
                            (Text(Image(systemName: "command")) + Text(Image(systemName: "return")))
                                .opacity(0.6)
                                .bold()
                                .padding(3)
                                .background {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(.regularMaterial)
                                }
                        }
                    }
                    .keyboardShortcut(.return, modifiers: .command)
                    .buttonStyle(.plain)
                    Text("Change Selection")
                    Button {
                        calcSelection()
                    } label: {
                        HStack {
                            (Text(Image(systemName: "command")) + Text("A"))
                                .opacity(0.6)
                                .bold()
                                .padding(3)
                                .background {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(.regularMaterial)
                                }
                        }
                    }
                    .keyboardShortcut("a", modifiers: .command)
                    .buttonStyle(.plain)
                    Text("/")
                    Button {
                        calcSelection(up: false)
                    } label: {
                        HStack {
                            (Text(Image(systemName: "command")) + Text("D"))
                                .opacity(0.6)
                                .bold()
                                .padding(3)
                                .background {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(.regularMaterial)
                                }
                        }
                    }
                    .keyboardShortcut("d", modifiers: .command)
                    .buttonStyle(.plain)
                }
                
                .frame(maxWidth: .infinity)
                .padding(7)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.ultraThinMaterial)
                }
                
                if let tab = contentViewModel.tabFor(id: contentViewModel.currentTab) {
                    ScrollView {
                        ScrollViewReader { reader in
                            VStack(alignment: .leading) {
                                ForEach(tab.restoredURLs, id: \.id) { item in
                                    HStack {
                                        if let title = item.title {
                                            Text(title)
                                        } else if let title = item.url?.absoluteString {
                                            Text(title)
                                        } else {
                                            Text("test")
                                        }
                                        Spacer()
                                    }
                                    .padding(5)
                                    .background {
                                        if item.id == selected {
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(lineWidth: 3)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            .onAppear() {
                                guard let first = tab.restoredURLs.first else {
                                    print("failed")
                                    return
                                }
                                selected = first.id
                            }
                            .onChange(of: selected) {
                                reader.scrollTo(selected)
                            }
                        }
                    }
                    .defaultScrollAnchor(.top)
                }
            }
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.thinMaterial)
                }
                .padding(10)
        }
        .frame(width: 350)
    }
    
    func calcSelection(up: Bool = true) {
        guard let tab = contentViewModel.tabFor(id: contentViewModel.currentTab), let currentIndex = tab.restoredURLs.firstIndex(where: {$0.id == selected}) else { return }
        if up {
            let index = currentIndex - 1 >= 0 ? currentIndex - 1: tab.restoredURLs.count - 1
            selected = tab.restoredURLs[index].id
        } else {
            let index = currentIndex + 1 < tab.restoredURLs.count ? currentIndex + 1: 0
            selected = tab.restoredURLs[index].id
        }
    }
}

#Preview {
    @Previewable @State var contentViewModel = ContentViewModel(id: "window1")
    @Previewable var container = try? ModelContainer(for: BackForwardListItem.self, configurations: .init(isStoredInMemoryOnly: true))
    if let container {
        RestoredHistory()
            .onAppear() {
                let context = ModelContext(container)
                let restored = [BackForwardListItem(sortingID: 1, url: URL(string: "https://miakoring.de"), title: "Mia Koring - Portfolio"),
                    BackForwardListItem(sortingID: 2, url: URL(string: "https://google.de"), title: "Google - Suche"),
                    BackForwardListItem(sortingID: 3, url: URL(string: "https://miakoring.de"), title: "Mia Koring - Portfolio")]
                for restore in restored {
                    context.insert(restore)
                }
                let tab = ATab(webViewModel: WebViewModel(contentViewModel: contentViewModel, appViewModel: AppViewModel()), restoredURLs: restored)
                
                contentViewModel.currentTab = tab.id
                contentViewModel.tabs.append(tab)
            }
            .environment(contentViewModel)
            .modelContainer(container)
            .frame(height: 300)
    }
}
