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
@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
public protocol LocalizableError: GenericError, CustomLocalizedStringResourceConvertible {
    
    /// The deprecated localized title of the error.
    ///
    /// Use an `AlertManager` title to identify the failed task or outcome, and ``messageResource`` to explain the underlying error.
    @available(*, deprecated, message: "Use the alert’s title and the error’s message instead.")
    var titleResource: LocalizedStringResource? { get }
    
    /// A localized, user-facing explanation of the underlying error.
    ///
    /// The message is shown in the body of `AlertManager`.
    var messageResource: LocalizedStringResource { get }
    
    /// The actions associated with the given error.
    @AlertAction.Builder
    func actions() -> [AlertAction]
    
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension LocalizableError {
    
    @available(*, deprecated, message: "Use the alert’s title and the error’s message instead.")
    @inlinable
    public var title: String? {
        titleResource?.localized()
    }
    
    @available(*, deprecated, message: "Use the alert’s title and the error’s message instead.")
    @inlinable
    public var titleResource: LocalizedStringResource? {
        nil
    }
    
    @inlinable
    public func actions() -> [AlertAction] {
        []
    }
    
    @inlinable
    public var message: String {
        messageResource.localized()
    }
    
    @inlinable
    public var localizedStringResource: LocalizedStringResource {
        self.messageResource
    }
    
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
extension LocalizedStringResource {
    
    /// Creates the localized String.
    @inlinable
    public func localized() -> String {
        String(localized: self)
    }
    
}
