//
//  Array Ex.swift
//  Essentials
//
//  Created by Vaida on 12/1/24.
//

import Testing
@testable
import Essentials


@Suite
struct SequenceTests {
    
    @Test
    func allEqual() {
        #expect(![1, 2, 3, 4].allEqual())
        #expect([1, 1].allEqual())
        #expect([1].allEqual())
        #expect([Int]().allEqual())
    }
    
    @Test
    func compacted() {
        #expect(([1, 2, 3, nil] as [Int?]).compacted() == [1, 2, 3])
    }
    
    @Test
    func flatten() {
        #expect(([[1], [2, 3], [3], [1]]).flatten() == [1, 2, 3, 3, 1])
    }
    
    @Test
    func onlyMatch() {
        
    }
    
    
}
