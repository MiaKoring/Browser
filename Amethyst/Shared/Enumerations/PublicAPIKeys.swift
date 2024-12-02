//
//  PublicAPIKeys.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 02.12.24.
//

enum PublicAPIKeys {
    case meili
}

extension PublicAPIKeys {
    var key: String {
        switch self {
        case .meili:
            "a0918724dcb71a2d5501b62a98b2e9dec8ef09e148ad57066e8b9d820065cd7d"
        }
    }
}
