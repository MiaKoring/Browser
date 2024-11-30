//
//  HostingWindowFinder.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 30.11.24.
//
import SwiftUI

struct HostingWindowFinder: NSViewRepresentable {
  var callback: (NSWindow?) -> ()
  
  func makeNSView(context: Self.Context) -> NSView {
    let view = NSView()
    DispatchQueue.main.async { [weak view] in
      self.callback(view?.window)
    }
    return view
  }
  func updateNSView(_ nsView: NSView, context: Context) {}
}
