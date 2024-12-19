//
//  Array Optimize.swift
//  Essentials
//
//  Created by Vaida on 12/19/24.
//


extension RandomAccessCollection where Index == Int {
    
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
