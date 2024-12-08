//
//  InputBarFunctions.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 02.12.24.
//
import Foundation
import MeiliSearch

extension InputBar {
    func timerSuggestionFetch() async {
        if let meili = appViewModel.meili {
            typealias MeiliResult = Result<Searchable<HistoryEntryResult>, Swift.Error>
            async let searchEngineItems = await SearchEngine.duckduckgo.quickResults(text)
            //async let serverItems = await suggestionsFromServer(for: text)
            async let meiliItems: [SearchHit<HistoryEntryResult>]? = await withCheckedContinuation { continuation in
                meili.index("history").search(SearchParameters(
                    query: text,
                    limit: 5,
                    attributesToSearchOn: ["title", "url"],
                    sort: ["amount:desc", "lastSeen:desc"],
                    showRankingScore: true
                )) { (result: MeiliResult) in
                    switch result {
                    case .success(let res):
                        continuation.resume(returning: res.hits)
                        print(res.hits)
                    case .failure(let error):
                        continuation.resume(returning: nil)
                        print(error.localizedDescription)
                    }
                }
            }
            
            let results = await Array(searchEngineItems.prefix(5)).sorted(by: {
                let a = $0.wholeMatch(of: Regexpr.urlWithoutProtocol.regex)
                let b = $1.wholeMatch(of: Regexpr.urlWithoutProtocol.regex)
                return a != nil && b == nil
            }).map({
                if let _ = $0.wholeMatch(of: Regexpr.urlWithoutProtocol.regex) {
                    SearchSuggestion(title: $0, urlString: "https://\($0)", origin: .searchEngine)
                } else {
                    SearchSuggestion(title: $0, urlString: "https://duckduckgo.com/?q=\($0.replacingOccurrences(of: " ", with: "+"))", origin: .searchEngine)
                }
            })
            //let results1 = await serverItems
            let meiliRes: [SearchSuggestion]? = await meiliItems?.compactMap {
                if $0._rankingScore ?? 0 > 0.6 {
                    return SearchSuggestion(title: $0.title.isEmpty ? $0.url: $0.title, urlString: $0.url, origin: .history)
                }
                return nil
            }
            makeResult(serverList: []/*results1*/, searchEngineList: results, meiliList: meiliRes)
            lastInput = text
        } else {
            async let searchEngineItems = await SearchEngine.duckduckgo.quickResults(text)
            async let serverItems = await suggestionsFromServer(for: text)
            
            let results = await Array(searchEngineItems.prefix(5)).sorted(by: {
                let a = $0.wholeMatch(of: Regexpr.urlWithoutProtocol.regex)
                let b = $1.wholeMatch(of: Regexpr.urlWithoutProtocol.regex)
                return a != nil && b == nil
            }).map({
                if let _ = $0.wholeMatch(of: Regexpr.urlWithoutProtocol.regex) {
                    SearchSuggestion(title: $0, urlString: "https://\($0)", origin: .searchEngine)
                } else {
                    SearchSuggestion(title: $0, urlString: "https://duckduckgo.com/?q=\($0.replacingOccurrences(of: " ", with: "+"))", origin: .searchEngine)
                }
            })
            let results1 = await serverItems
            makeResult(serverList: results1, searchEngineList: results, meiliList: nil)
            lastInput = text
        }
    }
    
    func suggestionsFromServer(for input: String) async -> [SearchSuggestion] {

        guard let url = URL(string: "https://amethyst.touchthegrass.de/indexes/urls/search?q=\(input.replacingOccurrences(of: " ", with: "+"))&limit=5&showRankingScore=true") else { return [] }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(PublicAPIKeys.meili.key)", forHTTPHeaderField: "Authorization")
        guard let response = try? await URLSession.shared.data(for: request) else { return [] }
        guard let data = try? JSONDecoder().decode(SuggestionGroup.self, from: response.0) else { return [] }
        return data.hits.compactMap({
            if $0._rankingScore > 0.6 {
                SearchSuggestion(title: $0.url, urlString: "https://\($0.url)", origin: .server)
            } else {
                nil
            }
        })
    }
    
    func makeResult(serverList: [SearchSuggestion], searchEngineList: [SearchSuggestion], meiliList: [SearchSuggestion]?) {
        var result: [SearchSuggestion] = []
        if let meiliList {
            if serverList.count + searchEngineList.count >= 2 {
                result = Array(meiliList.prefix(3))
            } else {
                result = Array(meiliList.prefix(5 - serverList.count + searchEngineList.count))
            }
        }
        for i in 0..<serverList.count {
            if result.count < 5 {
                result.append(serverList[i])
            } else {
                quickSearchResults = result
                return
            }
        }
        for i in 0..<searchEngineList.count {
            if result.count < 5 {
                result.append(searchEngineList[i])
            } else {
                quickSearchResults = result
                return
            }
        }
    }
    
    func updateSelection(up: Bool = true) {
        let currentIndex = selectedResult
        
        if up {
            let index = currentIndex - 1 >= 0 ? currentIndex - 1: quickSearchResults.count
            selectedResult = index
        } else {
            let index = currentIndex + 1 < quickSearchResults.count + 1 ? currentIndex + 1: 0
            selectedResult = index
        }
    }
}
