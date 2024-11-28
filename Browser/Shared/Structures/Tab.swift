//
//  Tab.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//

import WebKit

struct WKTab {
    var title: String
    var url: URL
    var backForwardList: WKBackForwardList
    var canGoBack: Bool
    var canGoForward: Bool
    var interactionState: Any?
    var magnification: CGFloat
    var pageZoom: CGFloat
    var selectedRanges: [NSValue]
    var microphoneCaptureState: WKMediaCaptureState
    var cameraCaptureState: WKMediaCaptureState
    var mediaPlaybackState: WKMediaPlaybackState
}
