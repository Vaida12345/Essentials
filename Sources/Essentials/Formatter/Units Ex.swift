//
//  Units Extensions.swift
//  The Stratum Module - Extended Functionalities
//
//  Created by Vaida on 2024/2/1.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation


extension UnitDuration {
    
    /// The day unit of duration.
    public static let day = UnitDuration(symbol: "day", converter: UnitConverterLinear(coefficient: 3600 * 24))
    
    /// The week unit of duration.
    public static let week = UnitDuration(symbol: "week", converter: UnitConverterLinear(coefficient: 3600 * 24 * 7))
    
    /// The month unit of duration.
    ///
    /// - Warning: For simplicity, a month is considered to be 30 days long.
    public static let month = UnitDuration(symbol: "month", converter: UnitConverterLinear(coefficient: 3600 * 24 * 30))
    
    /// The year unit of duration.
    ///
    /// - Warning: For simplicity, a month is considered to be 365 days long.
    public static let year = UnitDuration(symbol: "day", converter: UnitConverterLinear(coefficient: 3600 * 24 * 365))
    
}
