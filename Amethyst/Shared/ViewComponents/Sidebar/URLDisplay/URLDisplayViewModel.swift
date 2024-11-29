//
//  URLDisplayViewModel.swift
//  Amethyst
//
//  Created by Mia Koring on 28.11.24.
//

import SwiftUI
import SwiftData

struct URLDisplay: TabOpener {
    @Environment(AppViewModel.self) var appViewModel
    @Environment(\.modelContext) var context: ModelContext
    @State var showTextField: Bool = false
    @State var text: String = ""
    @State var url: String = ""
    @FocusState var urlTextFieldFocused: Bool
}
