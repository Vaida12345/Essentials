//
//  LocalizableError.swift
//  The Essentials Module
//
//  Created by Vaida on 8/11/23.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation


/// The localizable error that aims to replace `LocalizedError` by enabling Xcode to generate string resources automatically.
@available(macOS 13, iOS 16, watchOS 9, *)
public protocol LocalizableError: GenericError {
    
    /// The failure reason, shown as the message in ``AlertManager``.
    var messageResource: LocalizedStringResource { get }
    
}

@available(macOS 13, iOS 16, watchOS 9, *)
extension LocalizableError {
    
    public var message: String {
        messageResource.localized()
    }
    
}

@available(macOS 13, iOS 16, watchOS 9, *)
extension LocalizedStringResource {
    
    /// Creates the localized String.
    public func localized() -> String {
        var copy = self
        copy.locale = .current
        return String(localized: copy)
    }
    
}
