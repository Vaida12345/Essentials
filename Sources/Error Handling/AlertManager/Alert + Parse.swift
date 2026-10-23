//
//  Alert + Parse.swift
//  Essentials
//
//  Created by Vaida on 2026-09-03.
//

import Foundation


@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension AlertManager {
    
    /// Creates an alert manager with a given error.
    @inlinable
    @available(*, unavailable, renamed: "init(_:error:)", message: "Please use `init(_:error:)` instead")
    public init(_ error: some Error) {
        self.init("Operation failed", error: error)
    }
    
    /// Creates an alert manager with a given error.
    ///
    /// - Parameters:
    ///   - title: The title that identifies the failed task or outcome. When `error` is an `AlertManager`, this title replaces the nested alert's title.
    ///   - error: The underlying error whose message and actions are presented.
    ///   - completionHandler: The handler called after the alert is dismissed.
    public init(_ title: LocalizedStringResource, error: any Error, completionHandler: (@MainActor @Sendable () -> Void)? = nil) {
        let parsed = AlertManager.parseMessage(error: error)
        self.init(title: title, message: parsed.message, actions: parsed.actions, completionHandler: completionHandler)
    }
    
    
    fileprivate static func parseMessage(error: Error) -> ParsedError {
#if canImport(ErrorManager)
        if let error = error as? ErrorManager {
            return .raw(error.errorDescription ?? error.description)
        }
#endif
        
        if let error = error as? AlertManager {
            return ParsedError(message: error.messageResource, actions: error.actions)
        } else if let genericError = error as? (any GenericError) {
            return .raw(genericError.message) // use message instead of messageResource for localizableError, as the type is allowed to override the message.
        } else {
            let error = error as NSError
            if error.localizedDescription.hasPrefix("The operation couldn’t be completed.") {
                return .raw(error.localizedFailureReason?.trimmingCharacters(in: ["(", ")"]) ??
                            error.localizedDescription.trimmingPrefix(/The operation couldn’t be completed.\s?/).trimmingCharacters(in: ["(", ")"])
                )
            } else {
                return .raw(error.localizedDescription)
            }
        }
    }
    
    fileprivate struct ParsedError: Sendable, Equatable {
        let message: TextBox
        let actions: [AlertAction]
        
        static func raw(_ message: String) -> ParsedError {
            .init(message: .raw(message), actions: [])
        }
    }
    
    
}
