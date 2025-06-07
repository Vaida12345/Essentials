//
//  Async Extensions.swift
//  The Essentials Module - Extended Functionalities
//
//  Created by Vaida on 5/3/22.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation


@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AsyncSequence {
    
    /// Returns a boolean value determining whether all the elements in the array are equal given the `predicate`.
    ///
    /// - Parameters:
    ///   - predicate: A closure which returns a boolean value determining whether its two arguments are equal.
    ///
    /// - Returns: The return value is `true` if the array is empty.
    ///
    /// - Complexity: O(*n*), where *n* is the length of array.
    @inlinable
    func allEqual(_ predicate: (_ lhs: Element, _ rhs: Element) async throws -> Bool) async throws -> Bool {
        
        var iterator = self.makeAsyncIterator()
        guard let firstElement = try await iterator.next() else { return true }
        
        while let nextElement = try await iterator.next() {
            guard try await predicate(firstElement, nextElement) else { return false }
        }
        
        return true
    }
    
    /// Returns a boolean value determining whether all the elements in the array are equal.
    ///
    /// - Returns: The return value is `true` if the array is empty.
    ///
    /// - Complexity: O(*n*), where *n* is the length of array.
    @inlinable
    func allEqual() async throws -> Bool where Element: Equatable {
        try await self.allEqual(==)
    }
    
    /// Returns all the values by iterating over the iterator.
    ///
    /// - Parameters:
    ///   - reservingCapacity: The capacity reserved, if known without complexity.
    ///
    /// - Complexity: O(*n*), where *n*: length of the iterator.
    @available(*, deprecated, renamed: "sequence")
    @inlinable
    func allObjects(reservingCapacity: Int? = nil) async throws -> [Element] {
        try await self.sequence
    }
    
    /// Returns the number of elements where the `predicate` is met.
    ///
    /// - Parameters:
    ///   - predicate: A closure that takes an element as its argument and returns a Boolean value that indicates whether the passed element represents a match.
    ///
    /// - Complexity: O(*n*), where *n*: The length of the array.
    @inlinable
    func count(where predicate: (Element) throws -> Bool) async rethrows -> Int {
        try await self.reduce(0) { $0 &+ (try predicate($1) ? 1 : 0) }
    }
    
    /// Returns a compact mapped sequence.
    ///
    /// - Important: This operation preserves order.
    ///
    /// - Complexity: O(*n*), where *n*: The length of the array, lazily.
    @inlinable
    func compacted<Unwrapped>() -> AsyncCompactMapSequence<Self, Unwrapped> where Element == Unwrapped? {
        self.compactMap { $0 }
    }
    
    /// Returns the only the element matches the predicate.
    ///
    /// - Returns: If multiple elements match, returns `nil`.
    @inlinable
    func onlyMatch(where predicate: (Element) async throws -> Bool) async rethrows -> Element? {
        var match: Element? = nil
        
        for try await element in self {
            guard try await predicate(element) else { continue }
            if match == nil {
                match = element
            } else {
                return nil
            }
        }
        
        return match
    }
    
}
