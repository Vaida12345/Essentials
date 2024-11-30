//
//  NeXTStep Extensions.swift
//  The Essentials Module - Extended Functionalities
//
//  Created by Vaida on 1/7/23.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
import UniformTypeIdentifiers


public extension NSColor {
    
    /// The Hexadecimal description of the image
    ///
    /// > Example:
    /// >
    /// > ```swift
    /// > NSColor.white.hexDescription // "ffffff"
    /// > ```
    @inlinable
    var hexDescription: String {
        let value = self.colorSpace != .sRGB ? self.usingColorSpace(.sRGB)! : self
        
        var red   = String(Int(value.redComponent   * 255), radix: 16, uppercase: false)
        var green = String(Int(value.greenComponent * 255), radix: 16, uppercase: false)
        var blue  = String(Int(value.blueComponent  * 255), radix: 16, uppercase: false)
        
        if red.count   == 1 {   red.insert("0",   at: red.startIndex) }
        if green.count == 1 { green.insert("0", at: green.startIndex) }
        if blue.count  == 1 {  blue.insert("0",  at: blue.startIndex) }
        
        return red + green + blue
    }
    
}
#endif
