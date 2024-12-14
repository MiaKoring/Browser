//
//  SettingsView.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 13.12.24.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            Tab {
                KeyBindsView()
            } label: {
                Label("Key Bindings", systemImage: "keyboard")
            }
        }
    }
}
