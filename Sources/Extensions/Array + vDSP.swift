//
//  Array + vDSP.swift
//  Essentials
//
//  Created by Vaida on 2025-06-09.
//

import Accelerate


// MARK: - Float

extension Array<Float> {
    
    /// Creates an array from the given stride.
    @inlinable
    public static func stride(
        from start: Element,
        through end: Element,
        count: Int
    ) -> Array {
        Array(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            initializedCount = count
            vDSP.formRamp(in: start ... end, result: &buffer)
        }
    }
    
    /// Creates an array from the given stride.
    @inlinable
    public static func stride(
        from start: Element,
        by stride: Element,
        count: Int
    ) -> Array {
        Array(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            initializedCount = count
            vDSP.formRamp(withInitialValue: start, increment: stride, result: &buffer)
        }
    }
    
}


// MARK: - Double

extension Array<Double> {
    
    /// Creates an array from the given stride.
    @inlinable
    public static func stride(
        from start: Element,
        through end: Element,
        count: Int
    ) -> Array {
        Array(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            initializedCount = count
            vDSP.formRamp(in: start ... end, result: &buffer)
        }
    }
    
    /// Creates an array from the given stride.
    @inlinable
    public static func stride(
        from start: Element,
        by stride: Element,
        count: Int
    ) -> Array {
        Array(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            initializedCount = count
            vDSP.formRamp(withInitialValue: start, increment: stride, result: &buffer)
        }
    }
    
}
