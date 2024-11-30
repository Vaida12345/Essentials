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
    @inlinable
    func allObjects(reservingCapacity: Int? = nil) async rethrows -> [Element] {
        var result: [Element] = []
        if let reservingCapacity { result.reserveCapacity(reservingCapacity) }
        
        for try await element in self {
            result.append(element)
        }
        
        return result
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


@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AsyncIteratorProtocol {
    
    /// Returns all the values by iterating over the iterator.
    ///
    /// - Parameters:
    ///   - reservingCapacity: The capacity reserved, if known without complexity.
    ///
    /// - Complexity: O(*n*), where *n*: length of the iterator.
    @inlinable
    mutating func allObjects(reservingCapacity: Int? = nil) async rethrows -> [Element] {
        var result: [Element] = []
        if let reservingCapacity { result.reserveCapacity(reservingCapacity) }
        
        while let next = try await self.next() {
            result.append(next)
        }
        
        return result
    }
    
}


@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Task where Success == Never, Failure == Never {
    
    /// Apply the time limit to `operation`.
    ///
    /// In the following example, it would print "cancelled", and throw ``TimeoutError``.
    ///
    /// ```swift
    ///try await Task.withTimeLimit(for: .seconds(3)) {
    ///     try await withTaskCancellationHandler {
    ///         try await Task.sleep(for: .seconds(5))
    ///         print("done")
    ///     } onCancel: {
    ///         print("cancelled")
    ///     }
    /// }
    /// ```
    ///
    /// - Note: At the end of the time limit, a task cancelation will be sent to `operation`, and it is your responsibility to check for cancelation, and stop the operation accordingly.
    ///
    /// - throws: ``TimeoutError``.
    ///
    /// ## Topics
    /// ### Error Type
    /// - ``TimeoutError``
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public static func withTimeLimit<T>(for duration: Duration, operation: @Sendable @escaping () async throws -> T) async throws -> T where T: Sendable {
        try await withThrowingTaskGroup(of: T.self) { taskGroup in
            taskGroup.addTask(operation: operation)
            taskGroup.addTask {
                try await Task.sleep(for: duration)
                throw TimeoutError(duration: duration)
            }
            for try await value in taskGroup {
                taskGroup.cancelAll()
                return value
            }
            fatalError("Should never reach here")
        }
    }
    
}

/// The operation has timed out.
///
/// This error is thrown by ``_Concurrency/Task/withTimeLimit(for:operation:)``.
///
/// In the following example, it would print "cancelled", and throw ``TimeoutError``, with ``duration`` of 3 sec.
///
/// ```swift
///try await Task.withTimeLimit(for: .seconds(3)) {
///     try await withTaskCancellationHandler {
///         try await Task.sleep(for: .seconds(5))
///         print("done")
///     } onCancel: {
///         print("cancelled")
///     }
/// }
/// ```
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public struct TimeoutError: GenericError {
    
    /// The duration for which the task has been executing.
    ///
    /// This value is the same as the `duration` parameter for ``_Concurrency/Task/withTimeLimit(for:operation:)``.
    public let duration: Duration
    
    
    fileprivate init(duration: Duration) {
        self.duration = duration
    }
    
    
    public var title: String {
        "Operation time out"
    }
    
    public var message: String {
        "The operation time out (\(self.duration.seconds, format: .timeInterval))"
    }
    
}

/*
/// The `async` version of the sequence.
///
/// Use this only when an `AsyncSequence` is explicitly required.
public struct AsyncSequenceContainer<Base>: AsyncSequence where Base: Sequence {
    
    private let base: Base
    
    
    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(iterator: base.makeIterator())
    }
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        
        var iterator: Base.Iterator
        
        public mutating func next() async -> Base.Element? {
            iterator.next()
        }
        
        public typealias Element = Base.Element
        
    }
    
    fileprivate init(base: Base) {
        self.base = base
    }
    
    public typealias Element = Base.Element
    
}


extension Sequence {
    
    /// The `async` version of the sequence.
    ///
    /// Use this only when an `AsyncSequence` is explicitly required.
    ///
    /// ## Topics
    /// ### The structure
    /// - ``AsyncSequenceContainer``
    public var async: AsyncSequenceContainer<Self> {
        AsyncSequenceContainer(base: self)
    }
    
}


/// Serialize two async sequences.
///
/// Do not initialize this structure directly, use ``AsyncSequence-Implementations/+(_:_:)``
public struct AsyncSerializedSequence<LHS, RHS>: AsyncSequence where LHS: AsyncSequence, RHS: AsyncSequence, LHS.Element == RHS.Element {
    
    private let lhs: LHS
    
    private let rhs: RHS
    
    
    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(lhs: lhs.makeAsyncIterator(), rhs: rhs.makeAsyncIterator())
    }
    
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        
        private var lhs: LHS.AsyncIterator
        
        private var rhs: RHS.AsyncIterator
        
        
        public mutating func next() async throws -> LHS.Element? {
            if let _lhs = try await lhs.next() {
                return _lhs
            }
            return try await rhs.next()
        }
        
        fileprivate init(lhs: LHS.AsyncIterator, rhs: RHS.AsyncIterator) {
            self.lhs = lhs
            self.rhs = rhs
        }
    }
    
    fileprivate init(lhs: LHS, rhs: RHS) {
        self.lhs = lhs
        self.rhs = rhs
    }
    
    public typealias Element = LHS.Element
}

extension AsyncSequence {
    
    /// Serialize two async sequences.
    ///
    /// ## Topics
    /// ### Structures
    /// - ``AsyncSerializedSequence``
    public static func +<RHS> (_ lhs: Self, _ rhs: RHS) -> AsyncSerializedSequence<Self, RHS> where Self.Element == RHS.Element {
        AsyncSerializedSequence(lhs: lhs, rhs: rhs)
    }
    
}
 */
