//
//  HistoryEntry.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 07.12.24.
//
import Foundation

struct HistoryEntry: Codable, Equatable {
    let id: UUID
    let title: String
    let url: String
    let lastSeen: Int
    let amount: Int
}

struct HistoryEntryResult: Codable, Equatable {
    let id: UUID
    let title: String
    let url: String
    let lastSeen: Int
    let amount: Int
    let _rankingScore: Double?
}
