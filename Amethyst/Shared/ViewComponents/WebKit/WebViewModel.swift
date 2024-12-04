//
//  WebViewModel.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//
import SwiftUI
import WebKit
import Combine

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
    
    private var webView: AWKWebView?
    private var cancellables: Set<AnyCancellable> = []
    private var processPool: WKProcessPool
    
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
        DispatchQueue.main.async {
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
                print("deinitialized WebViewModel")
            }
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

extension WebViewModel: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if let customAction = (webView as? AWKWebView)?.contextualMenuAction {
            print(customAction)
            switch customAction {
            case .openInNewTab:
                return openInNewTab(configuration: configuration)
            case .openInBackground:
                let newWebViewModel = WebViewModel(config: configuration, processPool: self.processPool, contentViewModel: contentViewModel, appViewModel: appViewModel)
                let newTab = ATab(webViewModel: newWebViewModel, restoredURLs: [])
                contentViewModel.tabs.append(newTab)
                print("openInBackground")
                return newWebViewModel.webView
            case .openInNewWindow:
                guard let url = navigationAction.request.url, let open = appViewModel.openWindow else { return nil }
                open(url)
                return nil
            }
        } else if navigationAction.targetFrame == nil {
            return openInNewTab(configuration: configuration)
        } else {
            return nil
        }
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        contentViewModel.handleClose()
    }
    
    func openInNewTab(configuration: WKWebViewConfiguration) -> WKWebView? {
        let newWebViewModel = WebViewModel(config: configuration, processPool: self.processPool, contentViewModel: contentViewModel, appViewModel: appViewModel)
        let newTab = ATab(webViewModel: newWebViewModel, restoredURLs: [])
        if let index = contentViewModel.tabs.firstIndex(where: {$0.id == contentViewModel.currentTab}) {
            contentViewModel.tabs.insert(newTab, at: index + 1)
        } else {
            contentViewModel.tabs.append(newTab)
        }
        contentViewModel.currentTab = newTab.id
        return newWebViewModel.webView
    }
}

extension WebViewModel: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        //TODO: verlauf
        /*if let url = navigationAction.request.url {
            switch navigationAction.navigationType {
            case .reload:
                break
            case .linkActivated:
                
            case .formSubmitted:
                <#code#>
            case .backForward:
                <#code#>
            case .formResubmitted:
                <#code#>
            case .other:
                <#code#>
            @unknown default:
                break
            }
        }*/
        return .allow
    }
}

extension WebViewModel {
    private func injectJavaScript() {
        let jsString = """
        var markInstance = new Mark(document.querySelector("body"));
        let highlights = [];
        let currentIndex = 0;
        
        function highlightText(searchTerm, options) {
            markInstance.unmark({"className": "amethystHighlight"});
            highlights = [];
            markInstance.mark(searchTerm, options); 
            return document.querySelectorAll('.amethystHighlight').length;
        }
        
        function removeHighlights() {
            markInstance.unmark({"className": "amethystHighlight"});
        }

        function navigateHighlights(direction) {
            if (highlights.length === 0) {
                highlights = document.querySelectorAll('.amethystHighlight');
            }
            if (highlights.length === 0) return 0;

            // Entferne vorherige Markierung
            highlights[currentIndex]?.classList.remove('amethystCurrent-highlight');

            // Aktualisiere den Index
            currentIndex += direction;
            if (currentIndex < 0) currentIndex = highlights.length - 1;
            if (currentIndex >= highlights.length) currentIndex = 0;

            // Markiere und scrolle zum aktuellen Treffer
            const current = highlights[currentIndex];
            current.classList.add('amethystCurrent-highlight');
            current.scrollIntoView({ behavior: 'smooth', block: 'center' });
            return currentIndex;
        }
        """
        let markScript = WKUserScript(source: markjs, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let userScript = WKUserScript(source: jsString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView?.configuration.userContentController.addUserScript(markScript)
        webView?.configuration.userContentController.addUserScript(userScript)
    }
    
    func injectCSSGlobally() {
        let cssString = """
        .amethystHighlight {
            background-color: yellow;
            
            color: black;
        }
        .amethystCurrent-highlight {
            background-color: orange;
        }
        """
        let jsCode = """
        var style = document.createElement('style');
        style.type = 'text/css';
        style.innerHTML = `\(cssString)`;
        document.head.appendChild(style);
        """
        let userScript = WKUserScript(source: jsCode, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView?.configuration.userContentController.addUserScript(userScript)
    }
    
    func navigateHighlight(forward: Bool, completion: @escaping(Any?, (any Error)?) -> Void) {
        let direction = forward ? 1 : -1
        let jsCode = "navigateHighlights(\(direction));"
        webView?.evaluateJavaScript(jsCode) { result, error in
            completion(result, error)
        }
    }
    func removeHighlights() {
        let jsCode = """
        removeHighlights();
        """
        webView?.evaluateJavaScript(jsCode) { result, error in
            if let error = error {
                print("Fehler beim Entfernen des Highlightings: \(error)")
            }
        }
    }
    func highlight(searchTerm: String, caseSensitive: Bool = false, completion: @escaping(Any?, (any Error)?) -> Void) {
        let jsCode = """
        var options = {
            "element": "span",
            "className": "amethystHighlight",
            "caseSensitive": \(caseSensitive ? "true": "false"),
        };
        highlightText('\(searchTerm)', options);
        """
        webView?.evaluateJavaScript(jsCode) { result, error in
            completion(result, error)
        }
    }
}
/*function highlightText(searchTerm, flags) {
removeHighlights();
highlights = [];
const bodyText = document.body.innerHTML;
const regex = new RegExp(`(${searchTerm})`, `${flags}`);
const highlighted = bodyText.replace(regex, '<span class="highlight">$1</span>');
document.body.innerHTML = highlighted;
return document.querySelectorAll('.highlight').length;
}
*/
