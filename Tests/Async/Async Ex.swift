//
//  Async Ex.swift
//  Essentials
//
//  Created by Vaida on 2025-06-07.
//

import Essentials
import Testing


@Suite
struct AsyncSequence {
    
    @Test func allEqual() async throws {
        let values = Array(repeating: 0, count: 10).async
        #expect(try await values.allEqual())
    }
    
    @Test func sequence() async throws {
        let values = Array(repeating: 0, count: 10).async
        #expect(try await values.sequence == Array(repeating: 0, count: 10))
    }
    
    @Test func count() async throws {
        let values = Array(repeating: 0, count: 10).async
        #expect(try await values.count(where: { $0 == 0 }) == 10)
    }
    
    @Test func compacted() async throws {
        let values = Array<Int?>(repeating: 0, count: 10).async
        #expect(try await values.compacted().sequence == Array(repeating: 0, count: 10))
    }
    
    @Test func onlyMatch() async throws {
        #expect(try await Array(1...10).async.onlyMatch(where: { $0 == 1 }) == 1)
        #expect(try await Array(1...10).async.onlyMatch(where: { $0 >= 1 }) == nil)
    }
    
    @Test func plus() async throws {
        let array = Array(1...3).async
        #expect(try await (array + array).sequence == [1, 2, 3, 1, 2, 3])
    }
    
    @Test func timeLimit() async throws {
        #expect(try await Task.withTimeLimit(for: .seconds(1), operation: { 1 }) == 1)
        await #expect(throws: TimeoutError.self) {
            try await Task.withTimeLimit(for: .seconds(1)) {
                try await Task.sleep(for: .seconds(1.1))
            }
        }
    }
    
}
