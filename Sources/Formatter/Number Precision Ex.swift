//
//  Number Precision Ex.swift
//  Essentials
//
//  Created by Vaida on 2025-05-17.
//

import Foundation


extension NumberFormatStyleConfiguration.Precision: @retroactive ExpressibleByIntegerLiteral {
    
    /// Indicates the precision should be `value` fraction length.
    @inlinable
    public init(integerLiteral value: IntegerLiteralType) {
        self = .fractionLength(value)
    }
    
}
