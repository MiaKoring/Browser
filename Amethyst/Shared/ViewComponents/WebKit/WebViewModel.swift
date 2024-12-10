//
//  WebViewModel.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//
import SwiftUI
import SwiftData
import WebKit
import Combine
import MeiliSearch

class WebViewModel: NSObject, ObservableObject {
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var currentURL: URL? = nil
    @Published var isLoading: Bool = false
    @Published var title: String? = nil
    @Published var isUsingCamera: WKMediaCaptureState = .none
    @Published var isUsingMicrophone: WKMediaCaptureState = .none
    @ObservedObject var contentViewModel: ContentViewModel
    @ObservedObject var appViewModel: AppViewModel
    
    var historyBlocked: [URL: Double] = [:]
    var webView: AWKWebView?
    var cancellables: Set<AnyCancellable> = []
    var processPool: WKProcessPool
    var downloadDelegate: DownloadDelegate = DownloadDelegate()
    var cache: Bool? = nil
    
    init(contentViewModel: ContentViewModel, appViewModel: AppViewModel) {
        self.processPool = contentViewModel.wkProcessPool
        self.contentViewModel = contentViewModel
        self.appViewModel = appViewModel
        super.init()
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.applicationNameForUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Safari/605.1.15"
        webConfiguration.defaultWebpagePreferences.allowsContentJavaScript = true
        webConfiguration.allowsInlinePredictions = true
        webConfiguration.allowsAirPlayForMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        webConfiguration.suppressesIncrementalRendering = false
        webConfiguration.processPool = processPool
        webConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webConfiguration.websiteDataStore = WKWebsiteDataStore.default()
        self.webView = AWKWebView(frame: .zero, configuration: webConfiguration)
        self.webView?.allowsBackForwardNavigationGestures = false
        self.webView?.underPageBackgroundColor = .myPurple
        self.webView?.uiDelegate = self
        self.webView?.navigationDelegate = self
        setupBindings()
        injectJavaScript()
        injectCSSGlobally()
    }
    
    init(processPool: WKProcessPool, contentViewModel: ContentViewModel, appViewModel: AppViewModel) {
        self.processPool = processPool
        self.contentViewModel = contentViewModel
        self.appViewModel = appViewModel
        super.init()
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.applicationNameForUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Safari/605.1.15"
        webConfiguration.defaultWebpagePreferences.allowsContentJavaScript = true
        webConfiguration.allowsInlinePredictions = true
        webConfiguration.allowsAirPlayForMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        webConfiguration.suppressesIncrementalRendering = false
        webConfiguration.processPool = processPool
        webConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webConfiguration.websiteDataStore = WKWebsiteDataStore.default()
        self.webView = AWKWebView(frame: .zero, configuration: webConfiguration)
        self.webView?.allowsBackForwardNavigationGestures = false
        self.webView?.underPageBackgroundColor = .myPurple
        self.webView?.uiDelegate = self
        self.webView?.navigationDelegate = self
        setupBindings()
        injectJavaScript()
        injectCSSGlobally()
    }
    
    init(processPool: WKProcessPool, restore tab: SavedTab, contentViewModel: ContentViewModel, appViewModel: AppViewModel) {
        self.processPool = processPool
        self.contentViewModel = contentViewModel
        self.appViewModel = appViewModel
        super.init()
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.applicationNameForUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1.1 Safari/605.1.15"
        webConfiguration.defaultWebpagePreferences.allowsContentJavaScript = true
        webConfiguration.allowsInlinePredictions = true
        webConfiguration.allowsAirPlayForMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        webConfiguration.suppressesIncrementalRendering = false
        webConfiguration.processPool = processPool
        webConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webConfiguration.websiteDataStore = WKWebsiteDataStore.default()
        self.webView = AWKWebView(frame: .zero, configuration: webConfiguration)
        self.webView?.allowsBackForwardNavigationGestures = false
        self.webView?.underPageBackgroundColor = .myPurple
        self.webView?.uiDelegate = self
        self.webView?.navigationDelegate = self
        if let url = tab.url {
            self.webView?.load(URLRequest(url: url))
        }
        
        setupBindings()
        injectJavaScript()
        injectCSSGlobally()
    }
    
    init(config: WKWebViewConfiguration, processPool: WKProcessPool, contentViewModel: ContentViewModel, appViewModel: AppViewModel) {
        self.processPool = processPool
        self.contentViewModel = contentViewModel
        self.appViewModel = appViewModel
        super.init()
        self.webView = AWKWebView(frame: .zero, configuration: config)
        self.webView?.allowsBackForwardNavigationGestures = false
        self.webView?.underPageBackgroundColor = .myPurple
        self.webView?.uiDelegate = self
        self.webView?.navigationDelegate = self
        
        setupBindings()
        injectJavaScript()
    }
    
    func deinitialize() {
        Task {
            await self.webView?.pauseAllMediaPlayback()
            await self.webView?.closeAllMediaPresentations()
            await self.webView?.setCameraCaptureState(.none)
            await self.webView?.setMicrophoneCaptureState(.none)
            guard let url = URL(string: "https://bloombuddy.touchthegrass.de") else { return }
            self.webView?.load( URLRequest(url: url))
            self.cancellables.removeAll()
            self.webView?.configuration.userContentController.removeAllUserScripts()
            self.webView?.stopLoading()
            self.webView?.removeFromSuperview()
            
            self.webView?.navigationDelegate = nil
            self.webView?.uiDelegate = nil
            self.webView = nil
        }
    }
    
    func goBack() {
        if canGoBack {
            webView?.goBack()
        }
    }
    
    func goForward() {
        if canGoForward {
            webView?.goForward()
        }
    }

    
    func getWebView() -> WKWebView {
        if let webView {
            return webView
        } else {
            let webConfiguration = WKWebViewConfiguration()
            webConfiguration.applicationNameForUserAgent = "Mozilla/5.0 (Macintosh; Apple Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Version/13.1 Safari/537.36"
            webConfiguration.defaultWebpagePreferences.allowsContentJavaScript = true
            webConfiguration.allowsInlinePredictions = true
            webConfiguration.allowsAirPlayForMediaPlayback = true
            webConfiguration.mediaTypesRequiringUserActionForPlayback = []
            webConfiguration.suppressesIncrementalRendering = false
            webConfiguration.processPool = processPool
            let webView = AWKWebView(frame: .zero, configuration: webConfiguration)
            self.webView = webView
            self.webView?.allowsBackForwardNavigationGestures = false
            self.webView?.underPageBackgroundColor = .myPurple
            setupBindings()
    
            return webView
        }
    }
    
    func load(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (Macintosh; Apple Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Version/13.1 Safari/537.36", forHTTPHeaderField: "User-Agent")
        webView?.load(request)
    }
    
    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        download.delegate = downloadDelegate
    }
        
    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        download.delegate = downloadDelegate
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        appendHistory()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        print(error.localizedDescription)
        print("provisional Navigation")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let response = navigationResponse.response as? HTTPURLResponse,
           let mimeType = response.mimeType,
           mimeType == "application/octet-stream" {
            print("octet download")
            decisionHandler(.cancel)
            downloadBinary(from: navigationResponse.response.url, withName: navigationResponse.response.suggestedFilename)
        } else {
            decisionHandler(.allow)
        }
    }

    func downloadBinary(from url: URL?, withName name: String?) {
        guard let url = url else { return }
        appViewModel.downloadManager.downloadFile(from: url, withName: name)
    }
    
    func appendHistory() {
        typealias MeiliResult = Result<Searchable<HistoryEntry>, Swift.Error>
        if let container = appViewModel.modelContainer, let url = currentURL, cache != nil {
            if let blockedTime = historyBlocked[url], blockedTime > Date().timeIntervalSinceReferenceDate {
                return
            }
            if let meili = appViewModel.meili {
                let index = meili.index("history")
                let param = SearchParameters(query: url.absoluteString, limit: 1, attributesToSearchOn: ["url"], filter: "url = '\(url.absoluteString)'")
                index.search(param) { (result: MeiliResult) in
                    switch result {
                    case .success(let result):
                        if let res = result.hits.first {
                            let new = HistoryEntry(id: res.id, title: self.title ?? res.title, url: res.url, lastSeen: Int(Date.now.timeIntervalSinceReferenceDate), amount: res.amount + 1)
                            Task {
                                do {
                                    _ = try await index.updateDocuments(documents: [new], primaryKey: "id")
                                } catch {
                                    print(error)
                                }
                            }
                        } else {
                            let new = HistoryEntry(id: UUID(), title: self.title ?? "", url: url.absoluteString, lastSeen: Int(Date.now.timeIntervalSinceReferenceDate), amount: 1)
                            Task {
                                do {
                                    _ = try await index.addDocuments(documents: [new], primaryKey: "id")
                                } catch {
                                    print(error)
                                }
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        if error.localizedDescription.contains("MeiliSearchApiError: Index `history` not found.") ||
                            error.localizedDescription.contains("is not filterable. This index does not have configured filterable attributes."){
                            Task {
                                do {
                                    _ = try await meili.createIndex(uid: "history", primaryKey: "id")
                                    _ = try await meili.index("history").updateSearchableAttributes(["url", "title"])
                                    _ = try await meili.index("history").updateFilterableAttributes(["url", "title", "id", "lastSeen", "amount"])
                                    _ = try await meili.index("history").updateSortableAttributes(["lastSeen", "amount"])
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
                }
            }
            let context = ModelContext(container)
            let rangeStart = Calendar.current.startOfDay(for: Date.now).timeIntervalSinceReferenceDate
            var dayDescriptor = FetchDescriptor<HistoryDay>(predicate: #Predicate<HistoryDay>{$0.time >= rangeStart})
            dayDescriptor.fetchLimit = 1
            if let day = try? context.fetch(dayDescriptor).first {
                day.historyItems.append(HistoryItem(time: Date.now.timeIntervalSinceReferenceDate, url: url, title: title))
                try? context.save()
            } else {
                let day = HistoryDay(time: Date().timeIntervalSinceReferenceDate, historyItems: [HistoryItem(time: Date.now.timeIntervalSinceReferenceDate, url: url, title: title)])
                context.insert(day)
                try? context.save()
            }
            historyBlocked[url] = Date.now.timeIntervalSinceReferenceDate + 300
        }
    }
    
    func setupBindings() {
        webView?.publisher(for: \.canGoBack)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.canGoBack = value
            }
            .store(in: &cancellables)

        webView?.publisher(for: \.canGoForward)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.canGoForward = value
            }
            .store(in: &cancellables)

        webView?.publisher(for: \.url)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.currentURL = value
            }
            .store(in: &cancellables)

        webView?.publisher(for: \.isLoading)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.isLoading = value
            }
            .store(in: &cancellables)

        webView?.publisher(for: \.title)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.title = value
            }
            .store(in: &cancellables)
        
        webView?.publisher(for: \.cameraCaptureState)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.isUsingCamera = value
            }
            .store(in: &cancellables)
        
        webView?.publisher(for: \.microphoneCaptureState)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.isUsingMicrophone = value
            }
            .store(in: &cancellables)
    }
}


