//
//  AsyncSequence.swift
//  Essentials
//
//  Created by Vaida on 1/4/25.
//


/// The `async` version of the sequence.
///
/// Use this only when an `AsyncSequence` is explicitly required.
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
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


@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
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


@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension AsyncSequence {
    
    /// Converts the AsyncSequence to an `Array`.
    ///
    /// This methods waits and collect the results of the async sequence.
    ///
    /// - returns: The returned `sequence` is in the same order as the input. The returned array is populated on return.
    ///
    /// - Complexity: O(*n*).
    @inlinable
    public var sequence: Array<Element> {
        consuming get async throws {
            var array: [Element] = []
            var iterator = self.makeAsyncIterator()
            
            while let next = try await iterator.next() {
                array.append(next)
            }
            
            return array
        }
    }
    
    
}
