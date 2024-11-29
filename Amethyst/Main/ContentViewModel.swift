//
//  ContentViewModel.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//
import SwiftUI
import SwiftData

struct ContentView {
    @Environment(AppViewModel.self) var appViewModel
    @Environment(\.modelContext) var context: ModelContext
    @State var showInputBar: Bool = false
    @State var inputBarText: String = ""
    @State var sidebarWidth: CGFloat = 308
    @State var showMacosWindowIconsAreaHovered: Bool = false
    @State var macosWindowIconsHovered: Bool = false
}

