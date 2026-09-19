//
//  DateFormatter.swift
//  The Essentials Module
//
//  Created by Vaida on 5/22/24.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation


extension FormatStyle where Self == Date.VerbatimFormatStyle {
    
    /// Formats the time interval.
    ///
    /// Use this to format a `Date`.
    ///
    /// > Example:
    /// > Create a formatted `String`.
    /// >
    /// > ```swift
    /// > Date().formatted (
    /// >    .date("\(month: .wide) \(day: .defaultDigits)")
    /// > ) // May 22
    /// > ```
    @available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
    @inlinable
    public static func date(_ format: Date.FormatString,
                            locale: Locale? = Locale(identifier: "en_us"),
                            timeZone: TimeZone = .gmt,
                            calendar: Calendar = .init(identifier: .gregorian)
    ) -> Date.VerbatimFormatStyle {
        Date.VerbatimFormatStyle(format: format, locale: locale, timeZone: timeZone, calendar: calendar)
    }
    
}
