//
//  WKDownloadDelegate.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 04.12.24.
//
import WebKit
import Foundation

class DownloadDelegate: NSObject, WKDownloadDelegate {
    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String) async -> URL? {
        if let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
            let url = downloadsURL.appendingPathComponent(suggestedFilename)
            return url
        }
        return nil
    }
}
