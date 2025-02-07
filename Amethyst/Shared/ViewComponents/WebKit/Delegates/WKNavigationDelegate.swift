//
//  NavigationDelegate.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 04.12.24.
//
import SwiftData
import WebKit

extension WebViewModel: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        if let url = navigationAction.request.url, contentViewModel.isLoaded {
            switch navigationAction.navigationType {
            case .reload, .backForward, .formResubmitted, .formSubmitted:
                cache = nil
                break
            case .linkActivated:
                cache = true
            case .other:
                cache = true
            @unknown default:
                cache = nil
                break
            }
            print(url.absoluteString)
        }
        if navigationAction.shouldPerformDownload {
            return .download
        }
        return .allow
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
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        if let urlStr = (error as NSError).userInfo[NSURLErrorFailingURLStringErrorKey] as? String, let url = URL(string: urlStr) {
            print("Error: \(url.absoluteString)")
            self.currentURL = url
        }
        if error.localizedDescription.contains("NSURLErrorDomain error -999") { return }
        if ErrorIgnoreManager.isURLErrorIgnored(error) { return }
        self.error = error
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        if let urlStr = (error as NSError).userInfo[NSURLErrorFailingURLStringErrorKey] as? String, let url = URL(string: urlStr) {
            print("Error: \(url.absoluteString)")
            self.currentURL = url
        }
        
        if error.localizedDescription.contains("NSURLErrorDomain error -999") { return }
        if ErrorIgnoreManager.isURLErrorIgnored(error) { return }
        
        self.error = error
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        error = nil
        appendHistory()
    }
}
