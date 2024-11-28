//
//  URLDisplayViewModel.swift
//  Amethyst
//
//  Created by Mia Koring on 28.11.24.
//

import SwiftUI

struct URLDisplay {
    @Environment(AppViewModel.self) var appViewModel
    @State var showTextField: Bool = false
    @State var text: String = ""
    @State var url: String = ""
    @FocusState var urlTextFieldFocused: Bool
}
