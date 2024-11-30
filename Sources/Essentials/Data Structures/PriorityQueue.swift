//
//  PriorityQueue.swift
//  Algorithms
//
//  Created by Vaida on 10/18/22.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//


/// First in, first out Queue with weights using heap.
///
/// The type `Element` is the content, `W` is the type for weight.
public struct PriorityQueue<Element, W>: CustomReflectable where W: Comparable {
    
    private var contents: Heap<Node>
    
    private struct Node: Comparable {
        
        fileprivate var content: Element
        fileprivate var weight: W
        
        fileprivate init(_ content: Element, weight: W) {
            self.content = content
            self.weight = weight
        }
        
        fileprivate static func < (lhs: PriorityQueue<Element, W>.Node, rhs: PriorityQueue<Element, W>.Node) -> Bool {
            lhs.weight < rhs.weight
        }
        
        fileprivate static func == (lhs: PriorityQueue<Element, W>.Node, rhs: PriorityQueue<Element, W>.Node) -> Bool {
            lhs.weight == rhs.weight
        }
    }
    
    /// The number of elements in the queue.
    public var count: Int {
        self.contents.count
    }
    
    /// Returns whether the queue is empty.
    public var isEmpty: Bool {
        self.contents.isEmpty
    }
    
    /// The mirror to the queue.
    public var customMirror: Mirror {
        Mirror(self, children: Array(self.contents).map { ("\($0.content)", $0.weight) })
    }
    
    /// Creates the queue.
    ///
    /// - Parameters:
    ///   - isMaxHeap: If `true`, elements with higher `weight` will be dequeued first.
    public init(isMaxHeap: Bool = true) {
        self.contents = .init(isMaxHeap ? .maxHeap : .minHeap)
    }
    
    /// Up-heap
    ///
    /// - Complexity: O(log *n*), where *n*: length of heap
    public mutating func enqueue(_ content: Element, weight: W) {
        let node = Node(content, weight: weight)
        self.contents.append(node)
    }
    
    /// Enqueue an object whose weight is itself.
    ///
    /// - Complexity: O(log *n*), where *n*: length of heap
    @inlinable
    public mutating func enqueue(_ content: Element) where Element == W {
        self.enqueue(content, weight: content)
    }
    
    /// Up-heap
    ///
    /// - Complexity: O(log *n*), where *n*: length of heap
    @inlinable
    public mutating func enqueue(_ content: Element, weight: KeyPath<Element, W>) {
        self.enqueue(content, weight: content[keyPath: weight])
    }
    
    /// Dequeue the element of max / min priority.
    ///
    /// - Complexity: O(log *n*), where *n*: length of heap
    public mutating func dequeue() -> Element? {
        self.contents.removeFirst()?.content
    }
    
    /// Dequeue the element of max / min priority.
    ///
    /// - Parameters:
    ///   - weight: Pass a value if you need to know the weight. Otherwise, use ``dequeue()`` instead.
    ///
    /// - Complexity: O(log *n*), where *n*: length of heap
    public mutating func dequeue(weight: inout W) -> Element? {
        guard let value = self.contents.removeFirst() else { return nil }
        weight = value.weight
        return value.content
    }
}


extension PriorityQueue: IteratorProtocol {
    
    /// The next element of the iterator.
    @inlinable
    public mutating func next() -> Element? {
        self.dequeue()
    }
    
}

extension PriorityQueue: Sequence { }
