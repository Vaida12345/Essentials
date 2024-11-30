//
//  Global Functions.swift
//  The Essentials Module - Extended Functionalities
//
//  Created by Vaida on 6/13/24.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//


/// Returns a value clamped to a specified range.
///
/// Clamping ensures that a value, `x`, stays within a specified range. If the value is less than the minimum bound, it is set to the minimum bound, `min`. If the value is greater than the maximum bound, it is set to the maximum bound, `max`. If the value falls within the range, it remains unchanged.
///
/// - Parameters:
///   - x: The value to be clamped.
///   - min: The minimum bound of the range.
///   - max: The maximum bound of the range.
///
/// - Returns: A value clamped within the specified range.
///
/// - Complexity: O(1)
@inline(__always)
public func clamp<T>(_ x: T, min: T? = nil, max: T? = nil) -> T where T: Comparable {
    if let min,
       x < min {
        min
    } else if let max,
              x > max {
        max
    } else {
        x
    }
}
