//
//  GenericError.swift
//  The Essentials Module
//
//  Created by Vaida on 4/4/24.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation
import OSLog


/// A generic error.
///
/// All errors should conform to this protocol instead of `Error` or `LocalizedError`.
///
/// This structure is capable of
/// - Reporting error to `stdout`
/// - Display error to user using `AlertManager`
///
/// An error's ``message`` explains its underlying problem. When presenting an error with `AlertManager`, provide a title that identifies the failed task or outcome.
///
/// A customized error is recommended to be an `enum`.
/// ```swift
///  public enum ReadDataError: GenericError {
///     case invalidLength
///
///     public var message: String {
///         switch self {
///         case invalidLength:
///             "The length is not 16 bytes"
///         }
///     }
/// }
/// ```
///
/// > Tip:
/// > When forming a description for debugging purposes, it is recommended to use `String(reflecting:)` to obtain the debug description of an error.
/// >
/// > Nevertheless, when using `OSLog` to log an error, you can use `"\(error)"` because it supports the logging of errors using their debug descriptions.
///
/// ## Topics
/// ### Protocol Requirements
/// - ``message``
/// - ``details``
///
/// ### Deprecated
/// - ``title``
///
/// ### Default Implementations
/// - ``description``
/// - ``debugDescription``
/// - ``localizedDescription``
/// - ``errorDescription``
/// - ``failureReason``
public protocol GenericError: LocalizedError, CustomStringConvertible, CustomDebugStringConvertible, Equatable {
    
    /// The deprecated title of the error.
    ///
    /// Use an `AlertManager` title to identify the failed task or outcome, and ``message`` to explain the underlying error.
    @available(*, deprecated, message: "Use the alert’s title and the error’s message instead.")
    var title: String? { get }
    
    /// A user-facing explanation of the underlying error.
    ///
    /// The message is shown in the body of `AlertManager`.
    var message: String { get }
    
    /// Additional details of the error suitable for debugging.
    ///
    /// This message is attached to the ``debugDescription``. This message is not displayed to users through `AlertManager` and is intended for developers for debugging purposes.
    ///
    /// The default implementation returns `nil`.
    var details: String? { get }
    
}


extension GenericError {
    
    /// A description suitable for generic audience.
    ///
    /// - SeeAlso: ``debugDescription`` for debug details.
    @inlinable
    public var description: String {
        message
    }
    
    /// A description with debug details attached.
    ///
    /// You can obtain the debug description using `String(reflecting:)`.
    @inlinable
    public var debugDescription: String {
        if let details {
            self.description + "\n" + details
        } else {
            self.description
        }
    }
    
    /// Default implementation.
    @available(*, deprecated, message: "Use the alert’s title and the error’s message instead.")
    @inlinable
    public var title: String? {
        nil
    }
    
    /// Default implementation.
    @inlinable
    public var details: String? {
        nil
    }
    
    /// - Invariant: This is inherited from `GenericError.description`
    @inlinable
    public var localizedDescription: String {
        description
    }
    
    /// - Invariant: This is inherited from ``GenericError/description``
    @inlinable
    public var errorDescription: String? {
        description
    }
    
    /// - Invariant: This is inherited from ``GenericError/message``
    @inlinable
    public var failureReason: String? {
        self.message
    }
    
}


extension OSLogInterpolation {
    
    @inlinable
    mutating func appendInterpolation(_ error: @autoclosure @escaping () -> some GenericError) {
        self.appendInterpolation(error().debugDescription)
    }
    
}
