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
    public init(_ title: LocalizedStringResource, error: any Error, completionHandler: (@Sendable () -> Void)? = nil) {
        let error = AlertManager.parse(error: error)
        switch error {
        case .localized(let message, let actions):
            self.init(
                title: title,
                message: message,
                actions: actions,
                completionHandler: completionHandler
            )
        case .unlocalized(let message, let actions):
            self.init(
                title: title,
                message: .init(stringLiteral: message),
                actions: actions,
                completionHandler: completionHandler
            )
        }
    }
    
    
    fileprivate static func parse(error: Error) -> ParsedError {
#if canImport(ErrorManager)
        if let error = error as? ErrorManager {
            return .unlocalized(
                message: error.errorDescription ?? error.description,
                actions: []
            )
        }
#endif
        
        if let error = error as? AlertManager {
            return .localized(
                message: error.messageResource,
                actions: error.actions
            )
        } else if let localizableError = error as? (any LocalizableError) {
            return .localized(
                message: localizableError.messageResource,
                actions: localizableError.actions()
            )
        } else if let genericError = error as? any GenericError {
            return .unlocalized(
                message: genericError.message,
                actions: []
            )
        } else if let localizedError = error as? LocalizedError {
            return .unlocalized(
                message: localizedError.errorDescription ?? localizedError.failureReason ?? localizedError.recoverySuggestion ?? String(describing: localizedError),
                actions: []
            )
        } else {
            let error = error as NSError
            if error.localizedDescription.hasPrefix("The operation couldn’t be completed.") {
                return .unlocalized(
                    message: error.description,
                    actions: []
                )
            } else {
                return .unlocalized(
                    message: error.localizedDescription,
                    actions: []
                )
            }
        }
    }
    
    fileprivate enum ParsedError {
        case localized(message: LocalizedStringResource, actions: [AlertAction])
        case unlocalized(message: String, actions: [AlertAction])
    }
    
}
