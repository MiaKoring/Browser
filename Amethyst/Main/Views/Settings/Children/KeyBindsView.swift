//
//  KeyBindsView.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 13.12.24
//

import SwiftUI

struct KeyBindsView: View {
    @State var triggerEvaluation: Bool = false
    var body: some View {
        List(KeybindsGroup.allCases, id: \.self) { group in
            Section(group.rawValue) {
                ForEach(group.children, id: \.self) { keybind in
                    KeyBindsRow(keybind: keybind, triggerEvaluation: $triggerEvaluation)
                }
            }
        }
    }
}

#Preview {
    KeyBindsView()
}
