//
//  GenericError.swift
//  The Essentials Module
//
//  Created by Vaida on 4/4/24.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation


/// A generic error.
///
/// All errors should conform to this protocol instead of `Error` or `LocalizedError`.
///
/// This structure is capable of
/// - Reporting error to `stdout`
/// - Display error to user using `AlertManager`
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
/// ## Topics
/// ### Protocol Requirements
/// - ``title``
/// - ``message``
/// - ``details``
///
/// ### Default Implementations
/// - ``description``
/// - ``debugDescription``
/// - ``localizedDescription``
/// - ``errorDescription``
/// - ``failureReason``
public protocol GenericError: LocalizedError, CustomStringConvertible, CustomDebugStringConvertible, Equatable {
    
    /// The title of the error suitable for display to users.
    ///
    /// This message will be shown as the title in `AlertManager` if no other title is provided, otherwise it will be presented in the error description.
    ///
    /// The default implementation returns `nil`.
    var title: String? { get }
    
    /// The message of the error suitable for display to users.
    ///
    /// The message will be shown as the message in `AlertManager`.
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
    public var description: String {
        if let title {
            "\(title): \(message)"
        } else {
            message
        }
    }
    
    /// A description with debug details attached.
    public var debugDescription: String {
        if let details {
            self.description + "\n\(details)"
        } else {
            self.description
        }
    }
    
    /// Default implementation.
    public var title: String? {
        nil
    }
    
    /// Default implementation.
    public var details: String? {
        nil
    }
    
    /// - Invariant: This is inherited from `GenericError.description`
    public var localizedDescription: String {
        description
    }
    
    /// - Invariant: This is inherited from ``GenericError/description``
    public var errorDescription: String? {
        description
    }
    
    /// - Invariant: This is inherited from ``GenericError/message``
    public var failureReason: String? {
        self.message
    }
    
}
