//
//  Array & Collection Extensions.swift
//  The Stratum Module - Extended Functionalities
//
//  Created by Vaida on 5/20/22.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation


/// **Hierarchy**
/// ```
/// - Sequence (Iterator)
///     - Collection
///         - BidirectionalCollection
///             - StringProtocol - - - - - - - - - - - -
///             - RandomAccessCollection -             - String
///         - MutableCollection          - Array       -
///         - RangeReplaceableCollection - - - - - - - -
/// ```
///
/// **Notes**
///
/// `Sequence` only serves as the deliverer of the `Iterator`. `Sequence` can either be stable or volatile (elements being discarded after traversal). An `Iterator` itself can conform to `Sequence` by returning `self` in `makeIterator()` if it is volatile.
///
/// `Collection` is a stable sequence with addressable positions.
public extension Sequence {
    
    /// Returns a boolean value determining whether all the elements in the array are equal given the `predicate`.
    ///
    /// - Parameters:
    ///   - predicate: A closure which returns a boolean value determining whether its two arguments are equal.
    ///
    /// - Returns: The return value is `true` if the array is empty.
    ///
    /// - Complexity: O(*n*), where *n* is the length of array.
    @inlinable
    func allEqual(_ predicate: (_ lhs: Element, _ rhs: Element) throws -> Bool) rethrows -> Bool {
        
        var iterator = self.makeIterator()
        guard let firstElement = iterator.next() else { return true }
        
        while let nextElement = iterator.next() {
            guard try predicate(firstElement, nextElement) else { return false }
        }
        
        return true
    }
    
    /// Returns a boolean value determining whether all the elements in the array are equal.
    ///
    /// - Returns: The return value is `true` if the array is empty.
    ///
    /// - Complexity: O(*n*), where *n* is the length of array.
    @inlinable
    func allEqual() -> Bool where Element: Equatable {
        self.allEqual(==)
    }
    
    /// Returns the number of elements where the `predicate` is met.
    ///
    /// - Parameters:
    ///   - predicate: A closure that takes an element as its argument and returns a Boolean value that indicates whether the passed element represents a match.
    ///
    /// - Complexity: O(*n*), where *n*: The length of the array.
    @inlinable
    func count(where predicate: (Element) throws -> Bool) rethrows -> Int {
        try self.reduce(0) { $0 &+ (try predicate($1) ? 1 : 0) }
    }
    
    /// Returns a compact mapped sequence.
    ///
    /// - Complexity: O(*n*), where *n*: The length of the array.
    @inlinable
    func compacted<Unwrapped>() -> [Unwrapped] where Unwrapped? == Element {
        var result: [Unwrapped] = []
        
        for element in self {
            guard let element else { continue }
            result.append(element)
        }
        
        return result
    }
    
    /// Returns an array containing the concatenated results.
    ///
    /// - Complexity: O(*n*), where *n*: The length of the resulting array.
    @inlinable
    func flatten() -> [Element.Element] where Element: Sequence {
        var result: [Element.Element] = []
        result.reserveCapacity(self.map(\.underestimatedCount).reduce(0, +))
        
        for sequence in self {
            result.append(contentsOf: sequence)
        }
        return result
    }
    
    /// Returns the only the element matches the predicate.
    ///
    /// - Returns: If multiple elements match, returns `nil`.
    @inlinable
    func onlyMatch(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        var match: Element? = nil
        
        for element in self {
            guard try predicate(element) else { continue }
            if match == nil {
                match = element
            } else {
                return nil
            }
        }
        
        return match
    }
    
    /// Returns the result of combining the elements of the sequence using the given closure.
    ///
    /// This closure differs from the Swift `reduce` that the return value of the closure must be of type `Element`. This closure does not need an `initialResult`, as the first element is accepted.
    ///
    /// > Tip:
    /// > A `map` may required to transform the element beforehand.
    /// >
    /// > ```swift
    /// > // calculate the sum, with `0` being the initial value
    /// > [1, 2, 3, 4].reduce(0, +)
    /// >
    /// > // calculate the sum, with the actual first value `1` being the initial one
    /// > [1, 2, 3, 4].reduce(+)
    /// > ```
    ///
    /// - Parameters:
    ///   - nextPartialResult: A closure that combines an accumulating value and an element of the sequence into a new accumulating value, to be used in the next call of the nextPartialResult closure or returned to the caller.
    ///
    /// - Returns: `nil` when the sequence is empty.
    @inlinable
    func reduce(_ nextPartialResult: (Element, Element) throws -> Element) rethrows -> Element? {
        var iterator = self.makeIterator()
        guard var result = iterator.next() else { return nil }
        
        while let next = iterator.next() {
            result = try nextPartialResult(result, next)
        }
        
        return result
    }
    
}


public extension Collection {
    
    /// Drops first while the `predicate` satisfies.
    ///
    /// > Example:
    /// > ```swift
    /// > "   abc".dropFirst(while: \.isWhitespace)
    /// > // "abc"
    /// > ```
    ///
    /// - Complexity: O(*n*), where *n*: The number of elements dropped.
    @inlinable
    func dropFirst(while predicate: (Element) throws -> Bool) rethrows -> SubSequence {
        var droppedCount = 0
        
        for element in self {
            guard try predicate(element) else { break }
            droppedCount += 1
        }
        
        return self.dropFirst(droppedCount)
    }
    
    /// Drops last while the `predicate` satisfies.
    ///
    /// > Example:
    /// > ```swift
    /// > "abc   ".dropLast(while: \.isWhitespace)
    /// > // "abc"
    /// > ```
    ///
    /// - Complexity: O(*n*), where *n*: The number of elements dropped.
    @inlinable
    func dropLast(while predicate: (Element) throws -> Bool) rethrows -> SubSequence {
        guard !self.isEmpty else { return self[self.startIndex..<self.endIndex] }
        var index = self.endIndex
        self.formIndex(&index, offsetBy: -1)
        
        var droppedCount = 0
        let startIndex = self.startIndex
        
        while try predicate(self[index]) {
            droppedCount += 1
            
            guard index > startIndex else { break }
            self.formIndex(&index, offsetBy: -1)
        }
        
        return self.dropLast(droppedCount)
    }
    
    /// Finds the repeated elements.
    ///
    /// > Example:
    /// >
    /// > ```swift
    /// > let content = "fat.rat.eat.bat.cat.eat.fat.rat"
    /// > content.findRepeatedElements(ofLength: 3)
    /// > // [".ea", ".ra", "at.", "eat", "fat", "rat", "t.e"]
    /// > ```
    ///
    /// - Returns: The repeated elements; empty otherwise.
    ///
    /// - Complexity: O(*n* log *n*), where *n* is the length of the collection.
    @inlinable
    func findRepeatedElements(ofLength k: Int) -> [SubSequence] where Element: Equatable, SubSequence: Comparable {
        var slices: [SubSequence] = []
        var output: [SubSequence] = []
        
        slices.reserveCapacity(self.count)
        output.reserveCapacity(self.count - k - 1)
        
        var sliceIndex = self.startIndex
        while sliceIndex < endIndex {
            slices.append(self[sliceIndex..<self.endIndex])
            self.formIndex(after: &sliceIndex)
        }
        
        slices.sort()
        
        for i in 0..<self.count - k - 1 {
            
            let currentSlice = slices[i]
            let nextSlice = slices[i + 1]
            
            var currentSliceIndex = currentSlice.startIndex
            var nextSliceIndex = nextSlice.startIndex
            
            for _ in 0 ..< k { // use three variables to improve efficiency, hopefully.
                guard currentSliceIndex < currentSlice.endIndex && nextSliceIndex < nextSlice.endIndex else { break }
                guard currentSlice[currentSliceIndex] == nextSlice[nextSliceIndex] else { break }
                currentSlice.formIndex(after: &currentSliceIndex)
                nextSlice.formIndex(after: &nextSliceIndex)
            }
            
            let result = nextSlice[nextSlice.startIndex ..< nextSliceIndex]
            guard !output.contains(result) else { continue }
            output.append(result)
        }
        
        return output
    }
    
    /// Finds the index where the `n`th occurrence of the `element` is.
    ///
    /// > Example:
    /// >
    /// > ```swift
    /// > [1, 2, 3, 1].findIndex(of: 1, occurrence: 2) // 3
    /// > ```
    ///
    /// - Important: The number of occurrence, ie, `n`, starts from `1`.
    ///
    /// - Attention: The return value is `nil` if the number of presence of `element < n`.
    ///
    /// - Parameters:
    ///   - target: The element to search for.
    ///   - n: The number of occurrence.
    ///
    /// - Returns: The `n`th index where the `element` is; `nil` otherwise.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    @inlinable
    func findIndex(of target: Element, occurrence n: Int) -> Index? where Element: Equatable {
        guard self.contains(target) else { return nil }
        
        var foundCounter = 0
        var index = self.startIndex
        while index < self.endIndex {
            guard self[index] == target else { self.formIndex(after: &index); continue }
            foundCounter += 1
            guard foundCounter == n else { self.formIndex(after: &index); continue }
            return index
        }
        
        return nil
    }
    
    /// Returns the indexes where the `predicate` is met.
    ///
    /// - Parameters:
    ///   - predicate: A closure that takes an element as its argument and returns a Boolean value that indicates whether the passed element represents a match.
    @inlinable
    func indexes(where predicate: (Element) throws -> Bool) rethrows -> [Index] {
        var indexes: [Index] = []
        
        var index = self.startIndex
        while index < self.endIndex {
            if try predicate(self[index]) { indexes.append(index) }
            
            self.formIndex(after: &index)
        }
        
        return indexes
    }
    
    /// Returns the first index where the `sequence` is.
    ///
    /// > Example:
    /// >
    /// > ```swift
    /// > let content = [1, 2, 3, 1, 2, 4]
    /// > content.firstIndex(of: [1, 2, 4]) // 3..<6
    /// > ```
    ///
    /// - Warning: Do not use `self.contains(:_)` before this, otherwise it would be cost-inefficient. Use `if let` or `guard let` instead.
    ///
    /// - Parameters:
    ///   - sequence: The sequence to be found.
    ///
    /// - Returns: The first index where the `sequence` is; `nil` otherwise.
    ///
    /// - Complexity: O(*n m*), where *n* is the length of the collection, *m* is the length of the target sequence.
    @inlinable
    func firstIndex(of sequence: Self) -> Range<Index>? where Element: Equatable {
        guard !sequence.isEmpty else { return nil }
        guard !self.isEmpty else { return nil }
        guard sequence.count != 1 else {
            if let firstIndex = self.firstIndex(of: sequence.first!) {
                return firstIndex..<self.index(after: firstIndex)
            } else {
                return nil
            }
        }
        
        var elementIndex = self.startIndex // use index instead of int because String is NOT RandomAccessCollection
    outer: while elementIndex < self.index(self.endIndex, offsetBy: -sequence.count + 1) {
        var targetIndex = sequence.startIndex
        var newElementIndex = elementIndex // use two variables, but more time efficient, hopefully!
        while targetIndex < sequence.endIndex {
            guard sequence[targetIndex] == self[newElementIndex] else { self.formIndex(after: &elementIndex); continue outer }
            sequence.formIndex(after: &targetIndex)
            self.formIndex(after: &newElementIndex)
        }
        return elementIndex..<newElementIndex
    }
        
        return nil
    }
    
}


public extension RangeReplaceableCollection {
    
    /// Removes the repeated elements of an array, leaving only the entries different from each other.
    ///
    /// > Example:
    /// >
    /// > ```swift
    /// > [1, 2, 3, 1].unique() // [1, 2, 3]
    /// > ```
    ///
    /// - Returns: The array without repeated elements.
    ///
    /// - Complexity: O(*n*), where *n* is the length of this sequence.
    @inlinable
    func unique() -> Self where Element: Hashable {
        var container: Set<Int> = []
        var result = Self()
        self.forEach { element in
            guard container.insert(element.hashValue).inserted else { return }
            result.append(element)
        }
        return result
    }
    
}


public extension Array {
    
    /// Determines whether the sequence contains the sub-sequence.
    ///
    /// > Example:
    /// >
    /// > ```swift
    /// > [1, 2, 3, 1, 2, 3].contains([1, 2, 3]) // true
    /// > ```
    ///
    /// - Parameters:
    ///   - sequence: The sequence to be found.
    ///
    /// - Returns: `true` if the sequence contains the sub-sequence; `false` otherwise.
    ///
    /// - Complexity: O(*n m*) worse case, where *n* is the length of the collection, *m* is the length of the target sequence.
    @inlinable
    func contains(_ sequence: [Element]) -> Bool where Element: Equatable {
        guard !sequence.isEmpty else { return true }
        guard !self.isEmpty else { return false }
        guard sequence.count != 1 else { return self.contains(sequence.first!) }
        
        for elementIndex in 0..<self.count - sequence.count {
            guard sequence.first! == self[elementIndex] else { break }
            
            for targetIndex in 1..<sequence.count {
                guard sequence[targetIndex] == self[elementIndex + targetIndex] else { break }
            }
            return true
        }
        
        return false
    }
    
    /// Returns an array containing the concatenated results.
    ///
    /// - Complexity: O(*n*), where *n*: The length of the resulting array.
    @inlinable
    func flatten<T>() -> [T] where Element == Array<T> {
        let count = self.reduce(0) { $0 + $1.count }
        
        return Array<Element.Element>.init(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            let base = buffer.baseAddress!
            var move = 0
            
            for value in self {
                let count = value.count
                for i in 0..<count {
                    move &+= 1
                    (base + move).initialize(to: value[i])
                }
            }
            
            initializedCount = count
        }
    }
    
    /// Returns the element which is closest to the `target`.
    ///
    /// - Precondition: The smaller element would be returned.
    ///
    /// - Returns: The return value is `nil` if the array is empty.
    ///
    /// - Complexity: O(*n*), where *n* is the length of array.
    @inlinable
    func nearestElement<T: Comparable & SignedNumeric>(by predicate: (_ instance: Element) throws -> T) rethrows -> Element? {
        guard let firstElement = self.first else { return nil }
        guard self.count != 1 else { return firstElement }
        
        return try self.reduce(firstElement) { partialResult, element in
            abs(try predicate(element)) < abs(try predicate(partialResult)) ? element : partialResult
        }
    }
    
    /// Returns a new sequence in which all occurrences of a target sequence in the receiver are replaced by another given sequence.
    ///
    /// > Example:
    /// >
    /// > ```swift
    /// > [1, 2, 3].replacingOccurrences(of: [2, 3], with: [23]) // [1, 23]
    /// > ```
    ///
    /// - Parameters:
    ///   - replacement: The sequence with which to replace target.
    ///   - target: The sequence to replace.
    ///
    /// - Returns: A new sequence in which all occurrences of target in the receiver are replaced by replacement.
    @inlinable
    func replacingOccurrences(of target: [Element], with replacement: [Element]) -> Self where Element: Equatable {
        var content = self
        while let firstIndex = content.firstIndex(of: target) {
            content.replaceSubrange(firstIndex, with: replacement)
        }
        return content
    }
    
    /// Removes and returns the first `k` element of the collection.
    ///
    /// - Parameters:
    ///   - k: The first `k` elements were removed.
    ///
    /// - Returns: The removed elements.
    @discardableResult
    @inlinable
    mutating func removeFirst(k: Int) -> Self {
        guard self.count > k else { let value = self; self.removeAll(); return value }
        let returnValue = self[self.startIndex..<self.index(self.startIndex, offsetBy: k)]
        self.removeFirst(k)
        return Array(returnValue)
    }
    
    /// Returns a new sequence in which all occurrences of a target sequence in the receiver are removed.
    ///
    /// > Example:
    /// >
    /// > ```swift
    /// > [1, 2, 3].removingOccurrences(of: [2, 3]) //  [1]
    /// > ```
    ///
    /// - Parameters:
    ///   - target: The sequence to be removed.
    ///
    /// - Returns: A new sequence in which all occurrences of target in the receiver are removed.
    @inlinable
    func removingOccurrences(of target: [Element]) -> Self where Element: Equatable {
        var content = self
        while let firstIndex = content.firstIndex(of: target) {
            content.removeSubrange(firstIndex)
        }
        return content
    }
    
    /// Returns the elements of the sequence, sorted using the given predicate as the comparison between elements.
    ///
    /// - Important: Use this only when the cost is high.
    ///
    /// - Parameters:
    ///   - feature: The feature to be compared.
    ///   - areInIncreasingOrder: A boolean value indicating whether the rhs is greater than the lhs.
    ///
    /// - Returns: A sorted array of the sequence's elements.
    ///
    /// - Complexity: O(*n* log *n*), where *n* is the length of the sequence.
    @inlinable
    func sorted<T>(on feature: (Element) throws -> T, by areInIncreasingOrder: (T, T) throws -> Bool) rethrows -> [Element] {
        guard self.count > 1 else { return self }
        let reference = try self.map(feature)
        let indexes = try [Index](0..<self.count).sorted { try areInIncreasingOrder(reference[$0], reference[$1]) }
        return indexes.map { self[$0] }
    }
    
    
    /// Creates a new array containing the specified number of a single, repeated value.
    @inlinable
    static func repeating(_ repeatedValue: Element, count: Int) -> Array {
        .init(repeating: repeatedValue, count: count)
    }
    
}

public extension Array where Element: Hashable {
    
    /// Creates a tree out of the headers of segments
    ///
    /// ```swift
    /// let value = [
    ///     "a.b.c",
    ///     "a.b.d",
    ///     "ab",
    /// ]
    ///
    /// let segmented = value.map({ $0.split(separator: /\W/) })
    ///
    /// Array.group(segmented: segmented)
    /// ```
    /// ```
    /// ─
    /// ├─a
    /// │ ╰─b
    /// │   ├─d
    /// │   ╰─c
    /// ╰─ab
    /// ```
    ///
    /// - Returns: ``GroupedNode/root``
    static func group(segmented: [[Element]]) -> GroupedNode {
        group(node: .init(segmented: segmented))
    }
    
    private static func group(node: GroupedNode) -> GroupedNode {
        func groupNodes(nodes: [GroupedNode]) -> [GroupedNode] {
            var dictionary: [Element : [[Element]]] = [:]
            for element in nodes {
                switch element {
                case .children, .root:
                    fatalError()
                case .leaf(let array):
                    if let first = array.first {
                        dictionary[first, default: []].append(Array(array.dropFirst()))
                    }
                }
            }
            
            return dictionary.map { key, value in
                if value.count != 1 {
                    group(node: .children(head: key, children: value.map({ .leaf($0) })))
                } else {
                    GroupedNode.leaf([key])
                }
            }
        }
        
        switch node {
        case .root(let node):
            return .root(groupNodes(nodes: node))
            
        case .children(let t, let node):
            // need to expand
            return .children(head: t, children: groupNodes(nodes: node))
            
        case .leaf:
            return node
        }
    }
    
    /// A node
    indirect enum GroupedNode: CustomStringConvertible {
        case root([GroupedNode])
        /// A node
        ///
        /// ### Parameters
        ///
        /// - term head: The element in common
        /// - term children: The children
        case children(head: Element, children: [GroupedNode])
        case leaf([Element])
        
        public var description: String {
            String.recursiveDescription(of: self) { source in
                switch source {
                case .root(let nodes):
                    nodes
                case .children(_, let nodes):
                    nodes
                case .leaf:
                    nil
                }
            } description: { source in
                switch source {
                case .root:
                    "GroupedNode<\(Element.self)>"
                case .children(let t, _):
                    "\(t)"
                case .leaf(let leaf):
                    "\(leaf)"
                }
            }
        }
        
        init(segmented: [[Element]]) {
            self = .root(segmented.map { .leaf($0) })
        }
    }
}
