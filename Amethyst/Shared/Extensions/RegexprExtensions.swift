//
//  RegexExtensions.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//

import Foundation
extension Regexpr {
    var regex: Regex<(Substring, Optional<Substring>, Substring)> {
        switch self {
        case .url:
            try! Regex("https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,}\\b([-a-zA-Z0-9@:%_\\+.~#?&\\/\\/=]*)")
        case .urlWithoutProtocol:
            try! Regex("(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,}\\b([-a-zA-Z0-9@:%_\\+.~#?&\\/\\/=]*)")
        }
    }
}
