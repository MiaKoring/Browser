//
//  SearchEngine.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 02.12.24.
//

protocol SearchEngineAdaptor {
    static var name: String { get }
    static func quickResults(query: String) async -> [String]
}
