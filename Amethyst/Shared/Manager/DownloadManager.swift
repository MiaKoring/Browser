//
//  Download.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 10.12.24.
//
import SwiftUI

@Observable
class DownloadManager: NSObject, URLSessionDownloadDelegate {
    struct DownloadInfo {
        let originalURL: URL
        let targetURL: URL
        let downloadURL: URL
        var progress: Double
        var totalBytes: Int64
        var downloadedBytes: Int64
    }
    
    var activeDownloads: [URLSessionTask: DownloadInfo] = [:]
    private var session: URLSession!
        
    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: self, delegateQueue: .main)
    }
    
    func downloadFile(from url: URL, withName name: String?) {
        let downloadTask = session.downloadTask(with: url)
        
        // Downloads-Ordner
        let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        
        let filename = url.lastPathComponent
        let targetURL: URL = downloadsDirectory.appendingPathComponent(name ?? filename)
        let downloadSidecarURL = targetURL.appendingPathExtension("download")

        // Download-Info tracken
        activeDownloads[downloadTask] = DownloadInfo(
            originalURL: url,
            targetURL: targetURL,
            downloadURL: downloadSidecarURL,
            progress: 0.0,
            totalBytes: 0,
            downloadedBytes: 0
        )
        
        downloadTask.resume()
    }
    
    private func updateDownload(for task: URLSessionTask, progress: Double, downloadedBytes: Int64, totalBytes: Int64) {
        guard var downloadInfo = activeDownloads[task] else { return }
        
        downloadInfo.progress = progress
        downloadInfo.downloadedBytes = downloadedBytes
        downloadInfo.totalBytes = totalBytes
        activeDownloads[task] = downloadInfo
    }
    
    // Download-Delegate Methoden
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let downloadInfo = activeDownloads[downloadTask] else { return }
        
        do {
            // Temporäre Datei an Zielort verschieben
            try FileManager.default.moveItem(at: location, to: downloadInfo.targetURL)
            
            // .download Sidecar entfernen
            try? FileManager.default.removeItem(at: downloadInfo.downloadURL)
            
            
            // Download aus Tracking entfernen
            activeDownloads.removeValue(forKey: downloadTask)
        } catch {
            print("Download-Fehler: \(error.localizedDescription)")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let originalURL = downloadTask.originalRequest?.url else { return }
                
        let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let filename = originalURL.lastPathComponent
        let downloadURL = downloadsDirectory.appendingPathComponent(filename).appendingPathExtension("download")
        
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        
        updateDownload(for: downloadTask, progress: progress, downloadedBytes: totalBytesWritten, totalBytes: totalBytesExpectedToWrite)
    }
}
