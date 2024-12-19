//
//  Queue.swift
//  Algorithms
//
//  Created by Vaida on 10/17/22.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//


/// First in, first out Queue.
///
/// A queue operates considerably faster than an `Array` when both ``enqueue(_:)`` and ``dequeue()`` operations are required. If only `enqueue` is needed, using `Array.append` would outperform `enqueue` because `enqueue` involves individually allocating each node.
public struct Queue<Element> {
    
    private var first: Node?
    
    private var last: Node?
    
    /// The number of elements in the queue.
    ///
    /// - Complexity: O(*0*), stored property.
    public private(set) var count: Int
    
    /// An one-directional Node
    private final class Node {
        let content: Element
        var next: Node?
        
        init(_ content: Element) {
            self.content = content
            self.next = nil
        }
    }
    
    /// Returns whether the queue is empty.
    ///
    /// - Complexity: O(*1*)
    public var isEmpty: Bool {
        first == nil && last == nil
    }
    
    /// Crates an empty queue.
    public init() {
        self.first = nil
        self.last = nil
        self.count = 0
    }
    
    /// Append an element to the last.
    ///
    /// - Complexity: O(*1*)
    public mutating func enqueue(_ element: Element) {
        let node = Node(element)
        
        if first == nil {
            assert(last == nil)
            
            self.first = node
            self.last = node
        } else {
            assert(last != nil)
            
            self.last!.next = node
            self.last = node
        }
        
        self.count &+= 1
    }
    
    /// Removes and returns the first element in the queue.
    ///
    /// - Complexity: O(*1*)
    public mutating func dequeue() -> Element? {
        guard let first = self.first else { return nil }
        
        if self.last === first {
            self.first = nil
            self.last = nil
        } else {
            self.first = self.first!.next
        }
        
        count &-= 1
        return first.content
    }
    
}


extension Queue: IteratorProtocol {
    
    /// Returns the next element in the queue.
    ///
    /// - Complexity: O(*1*), alias to ``dequeue()``.
    @inlinable
    public mutating func next() -> Element? {
        self.dequeue()
    }
    
}

extension Queue: Sequence { }

extension Queue: CustomStringConvertible {
    
    /// The description to the queue.
    public var description: String {
        var current = self.first
        var elements: [String] = []
        elements.reserveCapacity(self.count)
        
        while let _current = current {
            elements.append("\(_current.content)")
            current = _current.next
        }
        
        return "[" + elements.joined(separator: ", ") + "]"
    }
    
}

extension Queue: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: Element...) {
        self.init()
        
        for element in elements {
            self.enqueue(element)
        }
    }
    
}
