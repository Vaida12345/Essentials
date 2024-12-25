//
//  Compression.swift
//  Essentials
//
//  Created by Vaida on 12/4/24.
//

import Foundation
import Compression


@available(macOS 10.15, iOS 13, watchOS 6, *)
public extension Data {
    
    /// Compress the data using the given algorithm.
    ///
    /// - Parameters:
    ///   - algorithm: The compression algorithm used. Use the default one for Apple platforms.
    ///   - pageSize: The block size. See discussion for more information.
    ///   - handler: The handler for partial data.
    ///
    /// - **Larger `pageSize`** (e.g., 64 KB) generally results in better compression ratios and more efficient processing due to reduced overhead and better utilization of the compression algorithm's capabilities.
    /// - **Smaller `pageSize`** may be suitable for memory-constrained environments or when low latency is critical, but at the cost of compression efficiency.
    @inlinable
    func withCompressionStream(using algorithm: Compression.Algorithm = .lzfse, pageSize: Int = 65536, handler: @escaping (Data) -> Void) throws {
        let outputFilter = try OutputFilter(.compress, using: algorithm) { data in
            guard let data else { return }
            handler(data)
        }
        
        var index = 0
        let bufferSize = self.count
        
        while true {
            let rangeLength = Swift.min(pageSize, bufferSize - index)
            
            let subdata = self.subdata(in: index ..< index + rangeLength)
            index += rangeLength
            
            try outputFilter.write(subdata)
            
            if (rangeLength == 0) { break }
        }
    }
    
    /// Compress the data using the given algorithm.
    ///
    /// - Parameters:
    ///   - algorithm: The compression algorithm used. Use the default one for Apple platforms.
    ///   - pageSize: The block size. See discussion for more information.
    ///
    /// - **Larger `pageSize`** (e.g., 64 KB) generally results in better compression ratios and more efficient processing due to reduced overhead and better utilization of the compression algorithm's capabilities.
    /// - **Smaller `pageSize`** may be suitable for memory-constrained environments or when low latency is critical, but at the cost of compression efficiency.
    ///
    /// - Tip: Use ``Foundation/Data/withCompressionStream(using:pageSize:handler:)`` for stream behavior.
    @inlinable
    func compressed(using algorithm: Compression.Algorithm = .lzfse, pageSize: Int = 65536) throws -> Data {
        var compressedData = Data()
        
        try self.withCompressionStream(using: algorithm, pageSize: pageSize) { data in
            compressedData.append(data)
        }
        
        return compressedData
    }
    
    /// Decompress the data using the given algorithm.
    @inlinable
    func decompressed(using algorithm: Compression.Algorithm = .lzfse, pageSize: Int = 65536) throws -> Data {
        var decompressedData = Data()
        
        var index = 0
        let bufferSize = self.count
        
        let inputFilter = try InputFilter(.decompress, using: algorithm) { (length: Int) -> Data? in
            let rangeLength = Swift.min(length, bufferSize - index)
            let subdata = self.subdata(in: index ..< index + rangeLength)
            index += rangeLength
            
            return subdata
        }
        
        while let page = try inputFilter.readData(ofLength: pageSize) {
            decompressedData.append(page)
        }
        
        return decompressedData
    }
    
}


@available(macOS 10.15, iOS 13, watchOS 6, *)
public extension Data {
    
    /// Decompress the data using the given algorithm.
    func makeDecompressionStream(using algorithm: Compression.Algorithm = .lzfse, pageSize: Int = 65536) throws -> DecompressionStream {
        try DecompressionStream(data: self, pageSize: pageSize, algorithm: algorithm)
    }
    
    /// An async decompression stream.
    struct DecompressionStream: AsyncIteratorProtocol {
        
        private let inputFilter: InputFilter<Data>
        
        private let pageSize: Int
        
        
        public func next() async throws -> Data? {
            try inputFilter.readData(ofLength: pageSize)
        }
        
        
        fileprivate init(data: Data, pageSize: Int, algorithm: Compression.Algorithm) throws {
            self.pageSize = pageSize
            
            let bufferSize = data.count
            var index = 0
            
            self.inputFilter = try InputFilter(.decompress, using: algorithm) { (length: Int) -> Data? in
                let rangeLength = Swift.min(length, bufferSize - index)
                let subdata = data.subdata(in: index ..< index + rangeLength)
                index += rangeLength
                
                return subdata
            }
        }
        
    }
    
    
}
