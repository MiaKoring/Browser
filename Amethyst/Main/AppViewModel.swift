//
//  AppViewModel.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//
import SwiftUI

@Observable
class AppViewModel: NSObject {
    var triggerNewTab: Bool = false
    var isSidebarShown: Bool = false
    var isSidebarFixed: Bool = false
    var tabs: [ATab] = []
    var currentTab: UUID?
}
