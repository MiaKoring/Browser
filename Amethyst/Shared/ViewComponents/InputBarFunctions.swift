//
//  InputBarFunctions.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 02.12.24.
//
import Foundation

extension InputBar {
    func timerSuggestionFetch() async {
        async let searchEngineItems = await SearchEngine.duckduckgo.quickResults(text)
        async let serverItems = await suggestionsFromServer(for: text)
        
        let results = await Array(searchEngineItems.prefix(5)).sorted(by: {
            if let regex = Regexpr.urlWithoutProtocol.regex {
                let a = $0.wholeMatch(of: regex)
                let b = $1.wholeMatch(of: regex)
                return a != nil && b == nil
            }
            return false
        }).map({
            if let regex = Regexpr.urlWithoutProtocol.regex, let _ = $0.wholeMatch(of: regex) {
                SearchSuggestion(title: $0, urlString: "https://\($0)", origin: .searchEngine)
            } else {
                SearchSuggestion(title: $0, urlString: "https://duckduckgo.com/?q=\($0.replacingOccurrences(of: " ", with: "+"))", origin: .searchEngine)
            }
        })
        let results1 = await serverItems
        makeResult(serverList: results1, searchEngineList: results)
        lastInput = text
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
    
    func makeResult(serverList: [SearchSuggestion], searchEngineList: [SearchSuggestion]) {
        var result: [SearchSuggestion] = []
        if searchEngineList.count >= 3 && serverList.count >= 2 {
            result.append(contentsOf: Array(serverList.prefix(2)))
            result.append(contentsOf: Array(searchEngineList.prefix(3)))
            quickSearchResults = result
            return
        }
        if searchEngineList.count < serverList.count {
            result.append(contentsOf: Array(serverList.prefix(5 - searchEngineList.count)))
            result.append(contentsOf: searchEngineList)
            quickSearchResults = result
            return
        }
        result.append(contentsOf: serverList)
        result.append(contentsOf: Array(searchEngineList.prefix(5 - serverList.count)))
        quickSearchResults = result
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
