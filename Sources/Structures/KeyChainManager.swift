//
//  KeyChainManager.swift
//  Essentials
//
//  Created by Vaida on 3/7/25.
//

import Foundation
import Security


/// The manager to interact with the KeyChain service, which offers a secure way to persist passwords and keys.
@available(*, deprecated, renamed: "KeyChain", message: "Use KeyChain from ViewCollection instead.")
public enum KeyChainManager {
    
    /// Persist the given data to keyChain service.
    ///
    /// This method will automatically update the value if it exists.
    public static func persist(_ data: Data, account: String, identifier: String = Bundle.main.bundleIdentifier!) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: identifier,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            if status == -25299 {
                try update(data, account: account, identifier: identifier)
            } else {
                throw Error(status: status)
            }
        }
    }
    
    /// Query the first match of given account and identifier.
    public static func query(account: String, identifier: String = Bundle.main.bundleIdentifier!) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: identifier,
            kSecAttrAccount as String: account,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { throw Error(status: status) }
        
        return data
    }
    
    /// Removes a key stored in keyChain.
    public static func delete(account: String, identifier: String = Bundle.main.bundleIdentifier!) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: identifier,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else { throw Error(status: status) }
    }
    
    /// Updates the given data to keyChain service.
    public static func update(_ data: Data, account: String, identifier: String = Bundle.main.bundleIdentifier!) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: identifier,
            kSecAttrAccount as String: account
        ]
        
        let payload: [String: Any] = [kSecValueData as String: data]
        
        let status = SecItemUpdate(query as CFDictionary, payload as CFDictionary)
        guard status == errSecSuccess else { throw Error(status: status) }
    }
    
    
    /// An error. as a wrapper to `OSStatus`.
    public struct Error: GenericError {
        
        private let status: OSStatus
        
        public var title: String? {
            "Keychain error"
        }
        
        public var message: String {
            SecCopyErrorMessageString(status, nil) as String? ?? "OSStatus code \(status)"
        }
        
        
        fileprivate init(status: OSStatus) {
            self.status = status
        }
    }
    
}
