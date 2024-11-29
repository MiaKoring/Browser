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
    
    private var webView: WKWebView?
    private var cancellables: Set<AnyCancellable> = []
    private var processPool: WKProcessPool
    
    init(processPool: WKProcessPool) {
        self.processPool = processPool
        super.init()
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.applicationNameForUserAgent = "Mozilla/5.0 (Macintosh; Apple Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Version/13.1 Safari/537.36"
        webConfiguration.defaultWebpagePreferences.allowsContentJavaScript = true
        webConfiguration.allowsInlinePredictions = true
        webConfiguration.allowsAirPlayForMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        webConfiguration.suppressesIncrementalRendering = false
        webConfiguration.processPool = processPool
        self.webView = WKWebView(frame: .zero, configuration: webConfiguration)
        self.webView?.allowsBackForwardNavigationGestures = false
        self.webView?.underPageBackgroundColor = .myPurple
        setupBindings()
    }
    
    init(processPool: WKProcessPool, restore tab: SavedTab) {
        self.processPool = processPool
        super.init()
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.applicationNameForUserAgent = "Mozilla/5.0 (Macintosh; Apple Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Version/13.1 Safari/537.36"
        webConfiguration.defaultWebpagePreferences.allowsContentJavaScript = true
        webConfiguration.allowsInlinePredictions = true
        webConfiguration.allowsAirPlayForMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        webConfiguration.suppressesIncrementalRendering = false
        webConfiguration.processPool = processPool
        self.webView = WKWebView(frame: .zero, configuration: webConfiguration)
        self.webView?.allowsBackForwardNavigationGestures = false
        self.webView?.underPageBackgroundColor = .myPurple
        if let url = tab.url {
            self.webView?.load(URLRequest(url: url))
        }
        
        setupBindings()
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
            let webView = WKWebView(frame: .zero, configuration: webConfiguration)
            self.webView = webView
            self.webView?.allowsBackForwardNavigationGestures = false
            self.webView?.underPageBackgroundColor = .myPurple
            setupBindings()
    
            return webView
        }
    }
    
    func load(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        webView?.load(URLRequest(url: url))
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

