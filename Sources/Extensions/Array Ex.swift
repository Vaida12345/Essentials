//
//  Array & Collection Extensions.swift
//  The Essentials Module - Extended Functionalities
//
//  Created by Vaida on 5/20/22.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation


// **Hierarchy**
// ```
// - Sequence (Iterator)
//     - Collection
//         - BidirectionalCollection
//             - StringProtocol - - - - - - - - - - - -
//             - RandomAccessCollection -             - String
//         - MutableCollection          - Array       -
//         - RangeReplaceableCollection - - - - - - - -
// ```
//
// **Notes**
//
// `Sequence` only serves as the deliverer of the `Iterator`. `Sequence` can either be stable or volatile (elements being discarded after traversal). An `Iterator` itself can conform to `Sequence` by returning `self` in `makeIterator()` if it is volatile.
//
// `Collection` is a stable sequence with addressable positions.
public extension Sequence {
    
    /// Returns a boolean value determining whether all the elements in the array are equal given the `predicate`.
    ///
    /// - Parameters:
    ///   - predicate: A closure which returns a boolean value determining whether its two arguments are equal.
    ///
    /// - Returns: The return value is `true` if the array is empty.
    ///
    /// - Complexity: O(*n*), where *n*: The length of the sequence.
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
    /// - Complexity: O(*n*), where *n*: The length of the sequence.
    @inlinable
    func allEqual() -> Bool where Element: Equatable {
        self.allEqual(==)
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
    ///
    /// - Complexity: O(*n*), where *n*: The length of sequence.
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
    ///
    /// - Complexity: O(*n*), where *n*: The length of the sequence.
    @inlinable
    func reduce(_ nextPartialResult: (Element, Element) throws -> Element) rethrows -> Element? {
        var iterator = self.makeIterator()
        guard var result = iterator.next() else { return nil }
        
        while let next = iterator.next() {
            result = try nextPartialResult(result, next)
        }
        
        return result
    }
    
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
    func unique() -> Array<Element> where Element: Hashable {
        var container: Set<Element> = []
        var result = [] as [Element]
        self.forEach { element in
            guard container.insert(element).inserted else { return }
            result.append(element)
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
    
    /// Subscript an element at the given `index` gracefully.
    ///
    /// Instead of throwing fatal error, this methods returns `nil` when `index` is out of bounds.
    @inlinable
    func element(at index: Index) -> Element? {
        guard index < self.endIndex, index >= self.startIndex else { return nil }
        return self[index]
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
    
}


public extension Collection where Index == Int {
    
    /// Retrieves the element at the given `relativeIndex`.
    ///
    /// Unlike the built-in `subscript`, this function takes the `startIndex` into account, enabling treating a `Slice` as a stand-alone collection.
    ///
    /// - Precondition: This function assumes the stride is `1`.
    @inlinable
    subscript(relative relativeIndex: Index) -> Element {
        self[self.startIndex &+ relativeIndex]
    }
    
    /// Retrieves the element at the given `relativeRange`.
    ///
    /// Unlike the built-in `subscript`, this function takes the `startIndex` into account, enabling treating a `Slice` as a stand-alone collection.
    ///
    /// - Precondition: This function assumes the stride is `1`.
    @inlinable
    subscript(relative relativeRange: Range<Index>) -> SubSequence {
        self[self.startIndex &+ relativeRange.lowerBound ..< self.startIndex &+ relativeRange.upperBound]
    }
    
    /// Retrieves the element at the given `relativeRange`.
    ///
    /// Unlike the built-in `subscript`, this function takes the `startIndex` into account, enabling treating a `Slice` as a stand-alone collection.
    ///
    /// - Precondition: This function assumes the stride is `1`.
    @inlinable
    subscript(relative relativeRange: ClosedRange<Index>) -> SubSequence {
        self[self.startIndex &+ relativeRange.lowerBound ... self.startIndex &+ relativeRange.upperBound]
    }
    
    /// Retrieves the element at the given `relativeRange`.
    ///
    /// Unlike the built-in `subscript`, this function takes the `startIndex` into account, enabling treating a `Slice` as a stand-alone collection.
    ///
    /// - Precondition: This function assumes the stride is `1`.
    @inlinable
    subscript(relative relativeRange: PartialRangeFrom<Index>) -> SubSequence {
        self[(self.startIndex &+ relativeRange.lowerBound)...]
    }
    
    /// Retrieves the element at the given `relativeRange`.
    ///
    /// Unlike the built-in `subscript`, this function takes the `startIndex` into account, enabling treating a `Slice` as a stand-alone collection.
    ///
    /// - Precondition: This function assumes the stride is `1`.
    @inlinable
    subscript(relative relativeRange: PartialRangeThrough<Index>) -> SubSequence {
        self[...(self.startIndex &+ relativeRange.upperBound)]
    }
    
    /// Retrieves the element at the given `relativeRange`.
    ///
    /// Unlike the built-in `subscript`, this function takes the `startIndex` into account, enabling treating a `Slice` as a stand-alone collection.
    ///
    /// - Precondition: This function assumes the stride is `1`.
    @inlinable
    subscript(relative relativeRange: PartialRangeUpTo<Index>) -> SubSequence {
        self[..<(self.startIndex &+ relativeRange.upperBound)]
    }
}


public extension Array {
    
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
    
    /// Returns the elements of the sequence, sorted using the given predicate as the comparison between elements.
    ///
    /// ```swift
    /// let students: Set = ["Kofi", "Abena", "Peter", "Kweku", "Akosua"]
    /// let descendingStudents = students.sorted(by: >)
    /// print(descendingStudents)
    /// // Prints "["Peter", "Kweku", "Kofi", "Akosua", "Abena"]"
    /// ```
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
        try self.sorted(by: { try areInIncreasingOrder(feature($0), feature($1)) })
    }
    
    
    /// Creates a new array containing the specified number of a single, repeated value.
    @inlinable
    static func repeating(_ repeatedValue: Element, count: Int) -> Array {
        .init(repeating: repeatedValue, count: count)
    }
    
}
