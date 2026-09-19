//
//  Global Functions.swift
//  The Essentials Module - Extended Functionalities
//
//  Created by Vaida on 6/13/24.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation


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
/// - precondition: When `max` must be greater than `min`.
@inlinable
public func clamp<T>(_ x: T, min: T? = nil, max: T? = nil) -> T where T: Comparable {
    assert(max == nil || min == nil || max! >= min!, "max must be >= min")
    
    return if let min,
       x < min {
        min
    } else if let max,
              x > max {
        max
    } else {
        x
    }
}


/// Linearly interpolates `x` from `domain` to `range`.
///
/// This function takes an input value `x` within a specified `domain` and maps it proportionally into a target `range`.
///
/// The `x` could be outside the `domain`, in which case the value will be clipped to bounds.
///
/// - Parameters:
///   - x: The input value to interpolate. May lie inside or outside `domain`.
///   - domain: The closed range representing the input bounds.
///   - range: The closed range representing the output bounds.
///
/// - Returns: The value of `x` remapped from `domain` into `range`.
///
/// - Complexity: O(1)
@inlinable
public func linearInterpolate<T>(_ x: T, in domain: ClosedRange<T> = 0...1, to range: ClosedRange<T> = 0...1) -> T where T: FloatingPoint {
    if x <= domain.lowerBound { return range.lowerBound }
    if x >= domain.upperBound { return range.upperBound }
    
    return range.lowerBound + (x - domain.lowerBound) / (domain.upperBound - domain.lowerBound) * (range.upperBound - range.lowerBound)
}


/// Redirects the standard output and captures the result.
///
/// - Returns: Empty string if the returned file handle is empty.
@inlinable
@available(macOS 10.15, iOS 13, watchOS 6, *)
public func withStandardOutputCaptured(_ body: () throws -> Void) throws -> Data {
    fflush(stdout)
    
    let pipe = Pipe()
    let oldStdout = dup(STDOUT_FILENO)
    
    do {
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        
        defer {
            fflush(stdout)
            dup2(oldStdout, STDOUT_FILENO)
            close(oldStdout)
        }
        
        try body()
        fflush(stdout)
        try pipe.fileHandleForWriting.close()
    }
    
    return try pipe.fileHandleForReading.readToEnd() ?? Data()
}

/// Redirects the standard output and captures the result.
///
/// - Returns: Empty string if the returned file handle is empty.
@inlinable
@available(macOS 10.15, iOS 13, watchOS 6, *)
public func withStandardOutputAsyncCaptured(_ body: () async throws -> Void) async throws -> Data {
    fflush(stdout)
    
    let pipe = Pipe()
    let oldStdout = dup(STDOUT_FILENO)
    
    do {
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        
        defer {
            fflush(stdout)
            dup2(oldStdout, STDOUT_FILENO)
            close(oldStdout)
        }
        
        try await body()
        fflush(stdout)
        try pipe.fileHandleForWriting.close()
    }
    
    return try pipe.fileHandleForReading.readToEnd() ?? Data()
}
