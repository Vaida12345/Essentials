//
//  ReserveWhitespace.swift
//  Essentials
//
//  Created by Vaida on 2025-05-17.
//

import Foundation


@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public struct ReserveWhitespaceFormatStyle: FormatStyle {
    
    let spaceCount: Int
    
    public typealias FormatInput = String
    public typealias FormatOutput = String
    
    public func format(_ input: String) -> String {
        return input.prepadding(toLength: spaceCount, withPad: " ")
    }
    
}


@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension FormatStyle where Self == ReserveWhitespaceFormatStyle {
    
    /// The format style that appends any necessary pre-paddings to ensure the space it takes is `count`.
    func reserveWhitespace(count: Int) -> Self {
        return ReserveWhitespaceFormatStyle(spaceCount: count)
    }
    
}
