//
//  Data Ex.swift
//  Essentials
//
//  Created by Vaida on 2025-06-07.
//

import Foundation
import Testing
import Essentials
import CryptoKit


@Suite
struct DataExTests {
    
    @Test func binaryDigits() async throws {
        let value: UInt16 = 0b1000101
        #expect(value == 69)
        #expect(value.data.binaryDigits == "0b01000101_00000000")
    }
    
    @Test func hexString() async throws {
        let value: UInt16 = 0b1000101
        #expect(value == 69)
        #expect(value.data.hexString == "4500")
        
        #expect(UInt16(data: Data(hexString: "4500")!) == value)
    }
    
    @Test func encryption() async throws {
        let data = Data(Array(1..<100 as Range<UInt8>))
        let key = SymmetricKey(size: .bits256)
        try #expect(data.encrypt(using: key).decrypt(using: key) == data)
    }
    
    @Test func compression() async throws {
        let source = "1234567890".data(using: .utf8)!
        #expect(try source.compressed(using: .zlib).decompressed(using: .zlib) == source)
    }
    
}
