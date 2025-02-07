//
//  IgnoredError.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 07.02.25.
//

import SwiftUI

enum IgnoredError: String, UserDefaultWrapper {
    case ignoredURLErrors
}

extension IgnoredError {
    var all: [String] {
        get {
            guard let data = self.data, let result = try? JSONDecoder().decode([String].self, from: data) else { return [] }
            return result
        }
        nonmutating set {
            do {
                let encoded = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(encoded, forKey: self.key)
            } catch {
                print("Error encoding shortcut: \(error)")
            }
        }
    }
}
