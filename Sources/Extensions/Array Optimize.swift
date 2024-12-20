//
//  Array Optimize.swift
//  Essentials
//
//  Created by Vaida on 12/19/24.
//


extension RandomAccessCollection where Index == Int {
    
    /// The max `member` index of this collection.
    @inlinable
    public func maxIndex<T, E>(of member: (Element) throws(E) -> T) throws(E) -> Index? where E: Error, T: Comparable {
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
    
    /// The max `member` of this collection.
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
    
    /// The max `member` of this collection.
    ///
    /// This is equivalent to
    /// ```swift
    /// self.map(member).max()
    /// ```
    /// But more efficient.
    @inlinable
    public func average<T, E>(of member: (Element) throws(E) -> T) throws(E) -> T? where E: Error, T: BinaryFloatingPoint {
        var i = self.startIndex
        var cumulative: T = 0
        while i < self.endIndex {
            let current = try member(self[i])
            cumulative += current
            i &+= 1
        }
        return cumulative / T(self.count)
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
