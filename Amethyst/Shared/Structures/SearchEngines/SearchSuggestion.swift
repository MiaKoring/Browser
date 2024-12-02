//
//  SearchSuggestion.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 02.12.24.
//
import Foundation

struct SearchSuggestion {
    let id = UUID()
    let title: String
    let urlString: String
    let origin: SearchSuggestionOrigin
}

