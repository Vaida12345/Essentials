//
//  TimeIntervalFormatter.swift
//  The Essentials Module
//
//  Created by Vaida on 2024/1/25.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation


/// Formats the time interval.
///
/// > Example:
/// > Use this to format a `Double`.
/// >
/// > ```swift
/// > "\(0.000012345, format: .timeInterval)" // 12.3µs
/// > ```
public struct TimeIntervalFormatter<FormatInput>: FormatStyle, Sendable where FormatInput: BinaryFloatingPoint {
    
    private let precision: Int
    
    
    /// Sets the precision of output.
    ///
    /// - Parameters:
    ///   - precision: The precision for the displayed value.
    public func precision(_ precision: Int) -> TimeIntervalFormatter {
        TimeIntervalFormatter(precision: precision)
    }
    
    /// Creates the formatted `String`.
    ///
    /// > Example:
    /// > Use this to format a `Double`.
    /// >
    /// > ```swift
    /// > "\(0.000012345, format: .timeInterval)" // 12.3µs
    /// > ```
    public func format(_ value: FormatInput) -> String {
        var value = Double(value)
        
        if value < 0     { return "\(value)s" }
        if value == 0    { return "0s" }
        if value < 1e-15 { return String(format: "%.\(precision)lfas", value * 1e18) }
        if value < 1e-12 { return String(format: "%.\(precision)lffs", value * 1e15) }
        if value < 1e-9  { return String(format: "%.\(precision)lfps", value * 1e12) }
        if value < 1e-6  { return String(format: "%.\(precision)lfns", value * 1e9)  }
        if value < 1e-3  { return String(format: "%.\(precision)lfµs", value * 1e6)  }
        if value < 1     { return String(format: "%.\(precision)lfms", value * 1e3)  }
        
        let base: Double = 60
        
        if value < base { return String(format: "%.\(precision)lfs",        value) }; value /= base
        if value < base { return String(format: "%.\(precision)lfmin",      value) }; value /= base
        if value < 24   { return String(format: "%.\(precision)lfhr",       value) }; value /= 24
        if value < 365  { return String(format: "%.\(precision)lfdays",     value) }; value /= 365
        if value < 365  { return String(format: "%.\(precision)lfyrs",      value) }; value /= 100
        if value < 100  { return String(format: "%.\(precision)lfcentries", value) }
        
        return String(format: "%.\(precision)gs", Double(value))

    }
    
    
    fileprivate init(precision: Int) {
        self.precision = precision
    }
    
    
    public typealias FormatOutput = String
    
}


@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension FormatStyle where Self == TimeIntervalFormatter<Double> {
    
    /// Formats the time interval.
    ///
    /// Use this to format a `Double`.
    ///
    /// > Example:
    /// > Use this to format a `Double`.
    /// >
    /// > ```swift
    /// > "\(0.000012345, format: .timeInterval)" // 12.3µs
    /// > ```
    public static var timeInterval: TimeIntervalFormatter<Double> {
        TimeIntervalFormatter(precision: 1)
    }
    
}


@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension FormatStyle where Self == TimeIntervalFormatter<Float> {
    
    /// Formats the time interval.
    ///
    /// Use this to format a `Double`.
    ///
    /// > Example:
    /// > Create a formatted `String`.
    /// >
    /// > ```swift
    /// > "\(0.000012345, format: .timeInterval)" // 12.3µs
    /// > ```
    public static var timeInterval: TimeIntervalFormatter<Float> {
        TimeIntervalFormatter(precision: 1)
    }
    
}
