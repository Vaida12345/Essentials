//
//  Math Extensions.swift
//  The Essentials Module - Arithmetic
//
//  Created by Vaida on 4/13/22.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Accelerate


public extension Sequence where Element: AdditiveArithmetic {
    
    /// The sum of the `Collection`. If the array is empty, the return value is `0`.
    @inlinable
    var sum: Element {
        self.reduce(into: Element.zero, { $0 += $1 })
    }
    
}

public extension Sequence where Element: SignedNumeric & Comparable {
    
    /// Returns the element which is closest to the `target` in the `Collection`.
    ///
    /// - Remark: Upon a tie, the leading element would be returned.
    ///
    /// - Returns: The return value is `nil` if the array is empty.
    ///
    /// - Complexity: O(*n*), where *n* is the length of array.
    @inlinable
    func nearestElement(to target: Element) -> Element? {
        var iterator = self.makeIterator()
        
        guard let firstElement = iterator.next() else { return nil }
        
        var minimumValue = firstElement
        var minimum = abs(firstElement - target)
        
        while let next = iterator.next() {
            let nextDistance = abs(next - target)
            if nextDistance < minimum {
                minimum = nextDistance
                minimumValue = next
            }
        }
        
        return minimumValue
    }
    
}


public extension Sequence where Element: BinaryFloatingPoint {
    
    /// The mean value of the `Collection`.
    @inlinable
    @available(*, deprecated, renamed: "mean", message: "Use `mean` instead")
    func average() -> Element? {
        self.mean
    }
    
    /// The mean value of this `Sequence`.
    ///
    /// Even when the collection is empty, the value is also well defined, to be `Element.zero`.
    ///
    /// - Note: This implementation does not use `Accelerate`.
    @inlinable
    var mean: Element? {
        var iterator = self.makeIterator()
        guard var sum = iterator.next() else { return nil }
        var count = 1
        while let next = iterator.next() {
            sum += next
            count &+= 1
        }
        return sum / Element(count)
    }
    
}


@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AccelerateBuffer where Element == Double {
    
    /// The mean value of this `Sequence`.
    ///
    /// Even when the collection is empty, the value is also well defined, to be `Element.zero`.
    ///
    /// - Note: This implementation does not use `Accelerate`.
    @inlinable
    var mean: Element? {
        guard count != 0 else { return nil }
        return vDSP.mean(self)
    }
    
    /// The sum of the `Collection`. If the array is empty, the return value is `0`.
    @inlinable
    var sum: Element {
        return vDSP.sum(self)
    }
    
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AccelerateBuffer where Element == Float {
    
    /// The mean value of this `Sequence`.
    ///
    /// Even when the collection is empty, the value is also well defined, to be `Element.zero`.
    ///
    /// - Note: This implementation does not use `Accelerate`.
    @inlinable
    var mean: Element? {
        guard count != 0 else { return nil }
        return vDSP.mean(self)
    }
    
    /// The sum of the `Collection`. If the array is empty, the return value is `0`.
    @inlinable
    var sum: Element {
        return vDSP.sum(self)
    }
    
}
