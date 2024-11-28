//
//  ContentViewModel.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//
import SwiftUI

struct ContentView {
    @Environment(AppViewModel.self) var appViewModel
    @State var showInputBar: Bool = false
    @State var inputBarText: String = ""
    @State var sidebarWidth: CGFloat = 300
}

