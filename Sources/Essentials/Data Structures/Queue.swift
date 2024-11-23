//
//  Queue.swift
//  The Stratum Module - Algorithms
//
//  Created by Vaida on 10/17/22.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//


/// First in, first out Queue.
public struct Queue<Element>: CustomStringConvertible {
    
    private var first: Node?
    
    private var last: Node?
    
    /// The number of elements in the queue.
    public private(set) var count: Int
    
    /// An one-directional Node
    private final class Node {
        var content: Element
        var next: Node?
        
        init(_ content: Element) {
            self.content = content
            self.next = nil
        }
    }
    
    /// Returns whether the queue is empty.
    public var isEmpty: Bool {
        first == nil && last == nil
    }
    
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
    
    /// Crates an empty queue.
    public init() {
        self.first = nil
        self.last = nil
        self.count = 0
    }
    
    /// Append an element to the last.
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
        
        self.count += 1
    }
    
    /// Removes and returns the first element in the queue.
    public mutating func dequeue() -> Element? {
        guard first != nil else { return nil }
        assert(last != nil)
        
        let first = self.first!
        if self.last === first {
            self.first = nil
            self.last = nil
        } else {
            self.first = self.first!.next
        }
        
        count -= 1
        return first.content
    }
    
}


extension Queue: IteratorProtocol {
    
    /// Returns the next element in the queue.
    @inlinable
    public mutating func next() -> Element? {
        self.dequeue()
    }
    
}

extension Queue: Sequence { }
