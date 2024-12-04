//
//  HistoryView.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 04.12.24.
//

import SwiftData
import SwiftUI

struct HistoryView: View {
    @Query(sort: [SortDescriptor<HistoryDay>(\.time, order: .reverse)], animation: .default) var days: [HistoryDay]
    
    var body: some View {
        BackgroundView(shouldRotate: false) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(days) { day in
                            DetailView(title: Text(
                                "\(Date(timeIntervalSinceReferenceDate: day.time).toString(with: "dd.MM.yyyy"))"
                            ), isExpanded: true) {
                                HistoryListView(items: day.historyItems.sorted(by: {$0.time > $1.time}), proxy: proxy)
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var context
    HistoryView()
        .modelContainer(for: HistoryDay.self, inMemory: true, isAutosaveEnabled: true) { result in
            switch result {
            case .success(let success):
                ModelContext(success).insert(HistoryDay(time: Date.now.timeIntervalSinceReferenceDate, historyItems: [HistoryItem(time: Date.now.timeIntervalSinceReferenceDate, url: URL(string: "https://miakoring.de")!, title: "Mia Koring - Portfolio")]))
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
        .frame(width: 500, height: 500)
}
