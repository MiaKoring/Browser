//
//  WKUIDelegate.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 04.12.24.
//
import WebKit

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
            print("was wird das jetzt? \(navigationAction.description)")
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
