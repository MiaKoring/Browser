//
//  Sidebar.swift
//  Amethyst
//
//  Created by Mia Koring on 28.11.24.
//
import SwiftUI

struct Sidebar {
    @Environment(AppViewModel.self) var appViewModel
    @State var isSideBarButtonHovered: Bool = false
}
