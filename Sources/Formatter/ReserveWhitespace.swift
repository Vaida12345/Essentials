//
//  ReserveWhitespace.swift
//  Essentials
//
//  Created by Vaida on 2025-05-17.
//

import Foundation


/// A format style that reserves the given amount of space using whitespace.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public struct ReserveWhitespaceFormatStyle: FormatStyle {
    
    private let spaceCount: Int
    
    public typealias FormatInput = String
    public typealias FormatOutput = String
    
    public func format(_ input: String) -> String {
        input.prepadding(toLength: spaceCount, withPad: " ")
    }
    
    fileprivate init(spaceCount: Int) {
        self.spaceCount = spaceCount
    }
    
}


@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension FormatStyle where Self == ReserveWhitespaceFormatStyle {
    
    /// The format style that appends any necessary pre-paddings to ensure the space it takes is `count`.
    static func reserveWhitespace(count: Int) -> ReserveWhitespaceFormatStyle {
        ReserveWhitespaceFormatStyle(spaceCount: count)
    }
    
}
