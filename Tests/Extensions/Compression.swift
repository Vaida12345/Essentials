//
//  Compression.swift
//  Essentials
//
//  Created by Vaida on 2025-06-07.
//

import Essentials
import Testing
import Foundation


@Suite
struct CompressionTests {
    
    @Test func main() async throws {
        let data = Data(Array(1..<100 as Range<UInt8>))
        try #expect(data.compressed().decompressed() == data)
    }
    
}
