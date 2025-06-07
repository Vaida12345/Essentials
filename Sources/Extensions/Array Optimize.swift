//
//  Array Optimize.swift
//  Essentials
//
//  Created by Vaida on 12/19/24.
//


extension RandomAccessCollection where Index == Int {
    
    /// The max `member` index of this collection.
    @inlinable
    public func maxIndex<T, E>(
        of member: (Element) throws(E) -> T // Experiment: The use of keyPath has significant performance implication on debug build, but insignificant on release builds.
    ) throws(E) -> Index? where E: Error, T: Comparable {
        var i = self.startIndex
        var maxIndex: Index? = nil
        var max: T? = nil
        while i < self.endIndex {
            let current = try member(self[i])
            if max == nil || current > max! {
                max = current
                maxIndex = i
            }
            i &+= 1
        }
        return maxIndex
    }
    
    /// The max `member` of this collection.
    ///
    /// This is equivalent to
    /// ```swift
    /// self.map(member).max()
    /// ```
    /// But more efficient.
    @inlinable
    public func max<T, E>(of member: (Element) throws(E) -> T) throws(E) -> T? where E: Error, T: Comparable {
        var i = self.startIndex
        var max: T? = nil
        while i < self.endIndex {
            let current = try member(self[i])
            if max == nil || current > max! {
                max = current
            }
            i &+= 1
        }
        return max
    }
    
    /// The min `member` index of this collection.
    @inlinable
    public func minIndex<T, E>(of member: (Element) throws(E) -> T) throws(E) -> Index? where E: Error, T: Comparable {
        var i = self.startIndex
        var minIndex: Index? = nil
        var min: T? = nil
        while i < self.endIndex {
            let current = try member(self[i])
            if min == nil || current < min! {
                min = current
                minIndex = i
            }
            i &+= 1
        }
        return minIndex
    }
    
    /// The min `member` of this collection.
    ///
    /// This is equivalent to
    /// ```swift
    /// self.map(member).min()
    /// ```
    /// But more efficient.
    @inlinable
    public func min<T, E>(of member: (Element) throws(E) -> T) throws(E) -> T? where E: Error, T: Comparable {
        var i = self.startIndex
        var min: T? = nil
        while i < self.endIndex {
            let current = try member(self[i])
            if min == nil || current < min! {
                min = current
            }
            i &+= 1
        }
        return min
    }
    
    /// The average `member` of this collection.
    ///
    /// This is equivalent to
    /// ```swift
    /// self.map(member).mean
    /// ```
    /// But more efficient.
    ///
    /// - SeeAlso:
    /// This is the does the same as ``average(of:)``.
    @inlinable
    public func mean<T, E>(of member: (Element) throws(E) -> T) throws(E) -> T? where E: Error, T: BinaryFloatingPoint {
        var i = self.startIndex
        var cumulative: T = 0
        while i < self.endIndex {
            let current = try member(self[i])
            cumulative += current
            i &+= 1
        }
        return cumulative / T(self.count)
    }
    
    /// The average `member` of this collection.
    ///
    /// This is equivalent to
    /// ```swift
    /// self.map(member).mean
    /// ```
    /// But more efficient.
    ///
    ///
    /// - SeeAlso:
    /// This is the does the same as ``mean(of:)``.
    @inlinable
    @available(*, deprecated, renamed: "mean")
    public func average<T, E>(of member: (Element) throws(E) -> T) throws(E) -> T? where E: Error, T: BinaryFloatingPoint {
        try mean(of: member)
    }
    
    /// An efficient forEach.
    @inlinable
    public func forEach<E>(_ body: (_ index: Index, _ element: Element) throws(E) -> Void) throws(E) -> Void where E: Error {
        var i = self.startIndex
        while i < self.endIndex {
            try body(i, self[i])
            i &+= 1
        }
    }
    
}


extension Array {
    
    /// An efficient mutating forEach.
    @inlinable
    public mutating func mutatingForEach<E>(_ body: (_ index: Index, _ element: inout Element) throws(E) -> Void) throws(E) -> Void where E: Error {
        var i = self.startIndex
        while i < self.endIndex {
            try body(i, &self[i])
            i &+= 1
        }
    }
    
}


extension RandomAccessCollection where Index == Int {
    
    /// Contiguous grouping of `self`.
    ///
    /// This method achieves grouping by iterating over each event, and identify the dividers.
    ///
    /// - term i: The index of current item.
    /// - term element: The value of current item.
    /// - term currentGroup: The elements that the current group contains.
    /// - term returns: A bool determining whether a new group should be created dividing `element` and its predecessor.
    ///
    /// ---
    /// ## Example
    ///
    /// To group the following into `[1, 2, 3], [1, 2], [1, 2, 3]`
    ///
    /// ```swift
    /// let array: [Int] = [1, 2, 3, 1, 2, 1, 2, 3]
    /// ```
    ///
    /// You can use the following method that identifies the dividers.
    /// ```swift
    /// array.divided { i, element, currentGroup in
    ///     !currentGroup.isEmpty && currentGroup.last! > element
    /// }
    /// ```
    public func divided(
        by shouldCreateNewGroup: (_ i: Int, _ element: Element, _ currentGroup: [Element]) -> Bool
    ) -> [[Element]] {
        var groups: [[Element]] = []
        var currentGroup: [Element] = []
        
        var i = self.startIndex
        while i < self.endIndex {
            let value = self[i]
            if shouldCreateNewGroup(i, value, currentGroup) {
                groups.append(currentGroup)
                currentGroup = []
            }
            currentGroup.append(value)
            
            i &+= 1
        }
        
        groups.append(currentGroup)
        return groups
    }
}
