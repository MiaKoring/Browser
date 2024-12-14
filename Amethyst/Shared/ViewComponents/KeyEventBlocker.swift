//
//  KeyEventBlocker.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 14.12.24.
//
import SwiftUI

struct KeyEventBlocker: NSViewRepresentable {
    let text: Binding<String>?
    let isFocused: FocusState<Bool>.Binding
    class Coordinator: NSObject {
        var eventMonitor: Any?
        let text: Binding<String>?
        let isFocused: FocusState<Bool>.Binding
        
        init(text: Binding<String>?, isFocused: FocusState<Bool>.Binding) {
            self.text = text
            self.isFocused = isFocused
            eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { key in
                guard isFocused.wrappedValue else { return key }
                print(key.modifierFlags)
                if let text, let character = key.characters?.first, (key.modifierFlags.contains(.command) || key.modifierFlags.contains(.control) || key.modifierFlags.contains(.shift) || key.modifierFlags.contains(.option)) {
                    text.wrappedValue = "\(key.modifierFlags.contains(.command) ? "⌘": "")\(key.modifierFlags.contains(.shift) ? "⇧": "")\(key.modifierFlags.contains(.option) ? "⌥": "")\(key.modifierFlags.contains(.control) ? "⌃": "")\(character.uppercased())"
                }
                return nil
            }
        }
        
        deinit {
            if let monitor = eventMonitor {
                NSEvent.removeMonitor(monitor)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: text, isFocused: isFocused)
    }
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}
