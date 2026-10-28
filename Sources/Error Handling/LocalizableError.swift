//
//  LocalizableError.swift
//  The Essentials Module
//
//  Created by Vaida on 8/11/23.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation


/// A localizable error that aims to replace `LocalizedError` by enabling Xcode to generate string resources automatically.
///
/// An error's ``messageResource`` explains its underlying problem. When presenting an error with `AlertManager`, provide a title that identifies the failed task or outcome.
///
/// The ``GenericError/message`` of the error is the localized ``messageResource`` by default.
@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
public protocol LocalizableError: GenericError, CustomLocalizedStringResourceConvertible {
    
    /// The deprecated localized title of the error.
    ///
    /// Use an `AlertManager` title to identify the failed task or outcome, and ``messageResource`` to explain the underlying error.
    @available(*, deprecated, message: "Use the alert’s title and the error’s message instead.")
    var titleResource: LocalizedStringResource? { get }
    
    /// A localized, user-facing explanation of the underlying error.
    ///
    /// The localized message is shown in the body of `AlertManager`.
    ///
    /// - Tip: If you are working inside a Swift Package, you want to declare the bundle of the string resource via `LocalizedStringResource(..., bundle: #bundle)`, or override ``GenericError/message`` with your own localization implementation.
    var messageResource: LocalizedStringResource { get }
    
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension LocalizableError {
    
    @available(*, deprecated, message: "Use the alert’s title and the error’s message instead.")
    @inlinable
    public var title: String? {
        if let titleResource {
            return String(localized: titleResource)
        } else {
            return nil
        }
    }
    
    @available(*, deprecated, message: "Use the alert’s title and the error’s message instead.")
    @inlinable
    public var titleResource: LocalizedStringResource? {
        nil
    }
    
    /// The localized ``messageResource``.
    ///
    /// This value will be used as message when presented using ``AlertManager``.
    ///
    /// - Tip: You can override this computed property with your own localization implementation of ``messageResource``.
    @inlinable
    public var message: String {
        String(localized: messageResource)
    }
    
    @inlinable
    public var localizedStringResource: LocalizedStringResource {
        self.messageResource
    }
    
}
