//
//  KeyChainManager.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 07.12.24.
//

import Foundation
import KeychainAccess

struct KeyChainManager {
    static private let service = "de.touchthegrass.BloomBuddy.app"
    static func setValue(_ value: String?, for key: KeychainKey) {
        let kc = Keychain(service: KeyChainManager.service).synchronizable(false).accessibility(.alwaysThisDeviceOnly)
        kc[key.rawValue] = value
    }
    
    static func getValue(for key: KeychainKey) -> String? {
        let kc = Keychain(service: KeyChainManager.service).synchronizable(false).accessibility(.alwaysThisDeviceOnly)
        return kc[key.rawValue]
    }

    static func generateSecureKey(length: Int) -> String? {
        var keyData = Data(count: length)
        let result = keyData.withUnsafeMutableBytes { buffer in
            SecRandomCopyBytes(kSecRandomDefault, length, buffer.baseAddress!)
        }
        
        guard result == errSecSuccess else {
            print("Failed to generate random bytes: \(result)")
            return nil
        }
        
        // Encode the bytes in Base64 (oder Hex, falls bevorzugt)
        return keyData.base64EncodedString()
    }
}
