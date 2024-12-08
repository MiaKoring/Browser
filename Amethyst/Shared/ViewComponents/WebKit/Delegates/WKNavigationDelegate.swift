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
        if let _ = navigationAction.request.url, contentViewModel.isLoaded {
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
        }
        if navigationAction.shouldPerformDownload {
            return .download
        }
        return .allow
    }
}
