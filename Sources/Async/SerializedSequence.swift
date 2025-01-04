//
//  AsyncSerializedSequence.swift
//  Essentials
//
//  Created by Vaida on 1/4/25.
//


/// Serialize two async sequences.
///
/// Do not initialize this structure directly, use ``AsyncSequence-Implementations/+(_:_:)``
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
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


@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
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
