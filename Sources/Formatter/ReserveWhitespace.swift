//
//  ReserveWhitespace.swift
//  Essentials
//
//  Created by Vaida on 2025-05-17.
//

import Foundation


/// A format style that reserves the given amount of space using whitespace.
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


public extension FormatStyle where Self == ReserveWhitespaceFormatStyle {
    
    /// The format style that appends any necessary pre-paddings to ensure the space it takes is `count`.
    static func reserveWhitespace(count: Int) -> ReserveWhitespaceFormatStyle {
        ReserveWhitespaceFormatStyle(spaceCount: count)
    }
    
}
