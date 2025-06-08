//
//  Extensions.swift
//  Essentials
//
//  Created by Vaida on 2025-06-07.
//

import Foundation
import Essentials
import Testing


@Suite
struct ExtensionTests {
    
    @Test func implies() async throws {
        #expect(true => true == true)
        #expect(true => false == false)
        #expect(false => true == true)
        #expect(false => false == true)
    }
    
    @Test func interpolations() async throws {
        #expect("\(true, isShown: false)" == "")
        #expect("\(true, isShown: true)" == "true")
        
        #expect("\(Optional<Bool>.none, map: { $0 })" == "")
        #expect("\(Optional<Bool>.some(true), map: { $0 })" == "true")
        
        #expect("\(1, format: .number)" == "1")
    }
    
    @Test func prepadding() async throws {
        #expect("1".prepadding(toLength: 3, withPad: " ") == "  1")
    }
    
    @Test func uuid() async throws {
        let id = UUID()
        #expect(UUID(data: id.data) == id)
    }
    
    @Test func realloc() async throws {
        var buffer = UnsafeMutableBufferPointer<Int>.allocate(capacity: 10)
        let _ = buffer.initialize(from: stride(from: 0, to: 10, by: 1))
        defer { buffer.deallocate() }
        
        buffer.reallocate(capacity: 20)
        
        #expect(buffer.count == 20)
        for i in 0..<10 {
            #expect(buffer[i] == i)
        }
    }
    
}
