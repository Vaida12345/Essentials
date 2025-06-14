//
//  Data Extensions.swift
//  The Essentials Module - Extended Functionalities
//
//  Created by Vaida on 2023/12/29.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation
import Compression


public extension Data {
    
    
    /// Explicitly present the underlying digits.
    ///
    /// Please note that arm64 uses little-endian for the order of bytes.
    ///
    /// ```swift
    /// let value: UInt16 = 0b1000101
    ///
    /// value // 69
    /// value.data.binaryDigits // 0b01000101_00000000
    /// ```
    @inlinable
    var binaryDigits: String {
        self.withUnsafeBytes { buffer in
            let buffer = buffer.bindMemory(to: UInt8.self)
            
            var results: String = "0b"
            results.reserveCapacity(self.count + buffer.count + 1 + 2)
            
            for i in 0..<buffer.count {
                for ii in 0..<8 {
                    let pivot = (0b10000000 as UInt8) >> ii
                    results.append("\(buffer[i] & pivot == pivot ? "1" : "0")")
                }
                
                
                if i != buffer.count - 1 {
                    results.append("_")
                }
            }
            
            return results
        }
    }
    
    /// Each two hexadecimal elements represents a `UInt8`.
    ///
    /// Please note that arm64 uses little-endian for the order of bytes.
    ///
    /// ```swift
    /// let value: UInt16 = 0b1000101
    ///
    /// value // 69
    /// value.data.hexString // 4500
    /// ```
    @inlinable
    var hexString: String {
        self.map { String(format: "%02hhx", $0) }.joined()
    }
    
    
    /// Initialize with a hex String.
    ///
    /// - Parameters:
    ///   - hexString: Each two hexadecimal elements represents a `UInt8`.
    @inlinable
    init?(hexString: String) {
        let (length, remainder) = hexString.count.quotientAndRemainder(dividingBy: 2)
        guard remainder == 0 else { return nil }
        var data = Data(capacity: length)
        var i = hexString.startIndex
        while i < hexString.endIndex {
            let j = hexString.index(i, offsetBy: 2)
            let bytes = hexString[i..<j]
            
            guard let num = UInt8(bytes, radix: 16) else { return nil }
            data.append(num)
            i = j
        }
        self = data
    }
    
}


#if canImport(CryptoKit)

import CryptoKit


@available(macOS 10.15, iOS 13, watchOS 6, *)
public extension Data {
    
    /// Encrypt data with the `key` provided.
    ///
    /// - Parameters:
    ///   - key: The encryption key, 256-bit keys are preferable for higher security.
    ///
    /// This method uses `AES.GCM` for encryption. Most `ARMv8` or later chips come with hardware acceleration for such algorithm, and runs considerably faster in a benchmark.
    @inlinable
    func encrypt(using key: SymmetricKey) throws -> Data {
        try AES.GCM.seal(self, using: key).combined! // Safe to unwrap, as it uses the default 12-byte nonce.
    }
    
    /// Decrypt data with the `key` provided.
    ///
    /// - Parameters:
    ///   - key: The encryption key used in ``encrypt(using:)``.
    @inlinable
    func decrypt(using key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: self)
        return try AES.GCM.open(sealedBox, using: key)
    }
    
    
    /// Encrypt data with the `key` provided.
    ///
    /// - Parameters:
    ///   - key: The encryption key, 256bit size.
    @available(*, deprecated, renamed: "encrypt(using:)", message: "Use `encrypt(using:)` for AES-GCM instead.")
    @inlinable
    func encrypt(with key: SymmetricKey) throws -> Data {
        try ChaChaPoly.seal(self, using: key).combined
    }
    
    /// Decrypt data with the `key` provided.
    ///
    /// - Parameters:
    ///   - key: The encryption key, 256bit size.
    @available(*, deprecated, renamed: "decrypt(using:)", message: "Use `decrypt(using:)` for AES-GCM instead.")
    @inlinable
    func decrypt(with key: SymmetricKey) throws -> Data {
        let sealedBox = try ChaChaPoly.SealedBox(combined: self)
        return try ChaChaPoly.open(sealedBox, using: key)
    }
    
}


@available(macOS 10.15, iOS 13, watchOS 6, *)
extension SHA256Digest {
    
    /// The raw data that made up the hash value. The length is 32 bytes.
    @inlinable
    public var data: Data {
        self.withUnsafeBytes { buffer in
            Data(bytes: buffer.baseAddress!, count: buffer.count)
        }
    }
    
}


@available(macOS 10.15, iOS 13, watchOS 6, *)
extension SymmetricKey {
    
    /// The raw data that made up the key.
    @inlinable
    public var data: Data {
        self.withUnsafeBytes { buffer in
            Data(bytes: buffer.baseAddress!, count: buffer.count)
        }
    }
    
}
#endif
