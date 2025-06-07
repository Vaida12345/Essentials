//
//  Date.swift
//  Essentials
//
//  Created by Vaida on 2025-06-07.
//

import Testing
import Essentials
import Foundation


@Suite
struct Formatters {
    
    @Test func date() async throws {
        #expect(Date(year: 2025, month: 5, day: 22).formatted(.date("\(month: .wide) \(day: .defaultDigits)")) == "May 22")
    }
    
    @Test func number() async throws {
        #expect(1.2345.formatted(.number.precision(2)) == "1.23")
    }
    
    @Test func string() async throws {
        #expect("1".formatted(.reserveWhitespace(count: 3)) == "  1")
    }
    
    @Test func timeInterval() async throws {
        #expect("\(0.000012345, format: .timeInterval)" == "12.3µs")
    }
    
}
