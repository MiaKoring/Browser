//
//  SearchEngineExtensions.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//

import Foundation
extension SearchEngine {
    func makeSearchUrl(_ input: String) -> URL? {
        switch self {
        case .duckduckgo:
            URL(string: "https://duckduckgo.com/?q=\(input.replacingOccurrences(of: " ", with: "+"))")
        }
    }
    
    func quickResults(_ input: String) async -> [String] {
        switch self {
        case .duckduckgo:
            await SEDuckDuckGo.quickResults(query: input)
        }
    }
    
    var root: String {
        switch self {
        case .duckduckgo:
            "https://duckduckgo.com"
        }
    }
}
