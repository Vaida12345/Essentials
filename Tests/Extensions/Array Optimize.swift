//
//  Array Optimize.swift
//  Essentials
//
//  Created by Vaida on 2025-06-07.
//

import Testing
import Essentials
import os


@Suite
struct ArrayOptimize {
    
    @Test func max() async throws {
        #expect([1, 2, 3].maxIndex(of: \.self) == 2)
        #expect([1, 2, 3].max(of: \.self) == 3)
        
        #expect(Array<Int>().maxIndex(of: \.self) == nil)
        #expect(Array<Int>().max(of: \.self) == nil)
    }
    
    @Test func min() async throws {
        #expect([1, 2, 3].minIndex(of: \.self) == 0)
        #expect([1, 2, 3].min(of: \.self) == 1)
        
        #expect(Array<Int>().minIndex(of: \.self) == nil)
        #expect(Array<Int>().min(of: \.self) == nil)
    }
    
    @Test func mean() async throws {
        #expect([1, 2, 3].mean(of: \.self) == 2)
    }
    
    @Test func forEach() async throws {
        var sum = 0
        Array(1...10).forEach { index, element in
            sum += element
        }
        #expect(sum == 55)
        
        sum = 0
        var array = Array(1...10)
        array.mutatingForEach { index, element in
            sum += element
        }
        #expect(sum == 55)
    }
    
    @Test func grouped() async throws {
        let array: [Int] = [1, 2, 3, 1, 2, 1, 2, 3]
        let grouped: [[Int]] = array.divided { i, element, currentGroup in
            !currentGroup.isEmpty && currentGroup.last! > element
        }
        #expect(grouped == [[1, 2, 3], [1, 2], [1, 2, 3]])
    }
    
}


struct ArrayOptimizeTrace {
    
    @Test func minIndex() async throws {
        let signposter = OSSignposter(subsystem: "Array + Optimize", category: .pointsOfInterest)
        let array = Array(1...1000_000_000)
        let _ = signposter.withIntervalSignpost("minIndex") {
            array.max(of: \.self)
        }
    }
    
}
