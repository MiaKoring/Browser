//
//  SearchViewModel.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 03.12.24.
//
import SwiftUI

struct DocumentSearchView: View {
    @Environment(ContentViewModel.self) var contentViewModel
    @ObservedObject var webViewModel: WebViewModel
    @State var text: String
    @State var count: Int?
    @State var pos: Int = 0
    @FocusState var textFieldFocused: Bool
    @State var caseSensitive: Bool = false
    var body: some View {
        HStack(spacing: 5) {
            TextField("Search", text: $text)
                .textFieldStyle(.plain)
                .font(.title2)
                .focused($textFieldFocused)
                .onSubmit {
                    webViewModel.highlight(searchTerm: text, caseSensitive: caseSensitive) { result, error in
                        count = result as? Int
                    }
                    contentViewModel.lastInlineQuery = text
                    pos = 0
                }
                .onKeyPress(.escape) {
                    contentViewModel.showInlineSearch = false
                    return.handled
                }
                .onKeyPress { event in
                    if event.key == .tab && event.modifiers.isEmpty {
                        webViewModel.navigateHighlight(forward: true) { result, _ in
                            pos = result as? Int ?? 0
                        }
                        return .handled
                    }
                    if event.key == KeyEquivalent("\u{19}") && event.modifiers == .shift {
                        webViewModel.navigateHighlight(forward: false) { result, _ in
                            pos = result as? Int ?? 0
                        }
                        return .handled
                    }
                    return .ignored
                }
            
            Image(systemName: "textformat.size")
                .bold()
                .frame(width: 20, height: 20)
                .background() {
                    if caseSensitive {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.thinMaterial)
                    }
                }
                .contentShape(RoundedRectangle(cornerRadius: 5))
                .onTapGesture {
                    withAnimation(.linear(duration: 0.1)) {
                        caseSensitive.toggle()
                    }
                }
            
            if let count {
                Text("\(count > 0 ? pos + 1: pos)/\(count)")
            } else {
                Text("0/?")
            }
            Button {
                webViewModel.navigateHighlight(forward: true) { result, _ in
                    pos = result as? Int ?? 0
                }
            } label: {
                Image(systemName: "chevron.down")
                    .bold()
                    .frame(width: 20, height: 20)
                    .background() {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.thinMaterial)
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 5))
            }
            .buttonStyle(.plain)
            Button {
                webViewModel.navigateHighlight(forward: false){ result, _ in
                    pos = result as? Int ?? 0
                }
            } label: {
                Image(systemName: "chevron.up")
                    .bold()
                    .frame(width: 20, height: 20)
                    .background() {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.thinMaterial)
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 5))
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.myPurple)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(lineWidth: 2)
                        .foregroundStyle(.thickMaterial)
                }
        }
        .onAppear(){
            textFieldFocused = true
        }
        .onDisappear() {
            webViewModel.removeHighlights()
        }
    }
}

#Preview {
    @Previewable @State var contentViewModel = ContentViewModel(id: "window1")
    @Previewable @State var appViewModel = AppViewModel()
    ZStack {
        if let tab = contentViewModel.tabs.first {
            WebView(viewModel: tab.webViewModel)
        }
        VStack {
            HStack {
                Spacer()
                if let tab = contentViewModel.tabs.first {
                    DocumentSearchView(webViewModel: tab.webViewModel, text: contentViewModel.lastInlineQuery)
                        .environment(contentViewModel)
                        .frame(maxWidth: 250)
                }
            }
            Spacer()
        }
        .frame(width: 600, height: 400)
        .onAppear() {
            let vm = WebViewModel(contentViewModel: contentViewModel, appViewModel: appViewModel)
            vm.load(urlString: "https://miakoring.de")
            contentViewModel.tabs.append(ATab(webViewModel: vm))
        }
    }
}
