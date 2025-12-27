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
        let allBitWidthEqual = [1, 2, 3, 4].allEqual(\.bitWidth)
        #expect(allBitWidthEqual)
        let notAllByteSwappedEqual = ![1, 2, 3, 4].allEqual(\.byteSwapped)
        #expect(notAllByteSwappedEqual)
        #expect([1, 2, 3, 4].allEqual({ $0 > 0 }))
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
        #expect(Array(1...10).onlyMatch(where: { $0 == 1 }) == 1)
        #expect(Array(1...10).onlyMatch(where: { $0 >= 1 }) == nil)
    }
    
    @Test
    func reduce() {
        #expect(Array(1...10).reduce(+) == 55)
    }
    
    @Test
    func unique() {
        #expect([1, 2, 3, 1].unique() == [1, 2, 3])
    }
    
}


@Suite
struct CollectionTests {
    
    @Test
    func drop() {
        #expect("   abc".dropFirst(while: \.isWhitespace) == "abc")
        #expect("abc   ".dropLast(while: \.isWhitespace) == "abc")
    }
    
    @Test
    func element() {
        #expect([1, 2, 3].element(at: 0) == 1)
        #expect([1, 2, 3].element(at: 3) == nil)
    }
    
    @Test
    func findIndex() {
        #expect([1, 2, 3, 1].findIndex(of: 1, occurrence: 2) == 3)
    }
    
    @Test
    func flatten() {
        #expect([[1, 2, 3, 1], [1]].flatten() == [1, 2, 3, 1, 1])
    }
    
    @Test
    func nearestElement() {
        #expect([1, 5, 5].nearestElement(to: 4) == 5)
    }
    
    @Test
    func sort() {
        #expect([4, 1, 2].sorted(on: \.self, by: <) == [1, 2, 4])
    }
    
    @Test
    func repeating() {
        #expect(Array<Int>.repeating(3, count: 2) == [3, 3])
    }
    
}
