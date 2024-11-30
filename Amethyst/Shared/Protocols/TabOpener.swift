//
//  TabOpener.swift
//  Amethyst
//
//  Created by Mia Koring on 28.11.24.
//
import SwiftData

protocol TabOpener {
    var contentViewModel: ContentViewModel { get }
    var appViewModel: AppViewModel { get }
    var context: ModelContext { get }
}
