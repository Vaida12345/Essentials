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
    @inline(__always)
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
    @inline(__always)
    @available(*, deprecated, renamed: "mean", message: "Use `mean` instead")
    func average() -> Element? {
        self.mean
    }
    
    /// The mean value of this `Sequence`.
    ///
    /// Even when the collection is empty, the value is also well defined, to be `Element.zero`.
    ///
    /// - Note: This implementation does not use `Accelerate`.
    @inline(__always)
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
    @inline(__always)
    var mean: Element? {
        guard count != 0 else { return nil }
        return vDSP.mean(self)
    }
    
    /// The sum of the `Collection`. If the array is empty, the return value is `0`.
    @inline(__always)
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
    @inline(__always)
    var mean: Element? {
        guard count != 0 else { return nil }
        return vDSP.mean(self)
    }
    
    /// The sum of the `Collection`. If the array is empty, the return value is `0`.
    @inline(__always)
    var sum: Element {
        return vDSP.sum(self)
    }
    
}


public extension Array {
    
    /// Find the elements which adds to the `sum` in this `Array`.
    ///
    /// - Source: Modified from Alistair Moffat, December 2012, Figure 9.4 PPSAA.
    ///
    /// - Parameters:
    ///   - sum: The target sum.
    ///
    /// - Returns: The elements which adds to `sum`; `nil` if not found.
    ///
    /// - Complexity: O(*n* log *n*), where *n* is the length of the sequence.
    func findElements(to sum: Element) -> [Element]? where Element: AdditiveArithmetic {
        
        /// Supporting class for `findElements(to:)`.
        ///
        /// This also serves as an example for divide and conquer.
        func findElements(to sum: Element, length: Int, result: FindElementsResult = FindElementsResult()) -> FindElementsResult {
            var result = result
            if sum == .zero {
                result.success = true
                return result
            } else if length == 0 {
                return result
            } else {
                let resulT = findElements(to: sum, length: length - 1, result: result)
                if resulT.success {
                    return resulT
                } else {
                    result.array.append(self[length - 1])
                    return findElements(to: sum - self[length - 1], length: length - 1, result: result)
                }
            }
        }
        
        let result = findElements(to: sum, length: self.count)
        if result.success {
            return result.array
        } else {
            return nil
        }
    }
    
    /// Supporting class for `findElements(to:)`.
    private struct FindElementsResult {
        var array: [Element] = []
        var success: Bool = false
    }
    
}
