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
    public init(_ title: LocalizedStringResource, error: any Error, completionHandler: (@Sendable () -> Void)? = nil) {
        let error = AlertManager.parse(error: error)
        switch error {
        case .localized(let _title, let _message, let actions):
            let message: LocalizedStringResource
            if let _title {
                if !_message.localized().isEmpty {
                    message = "\(_title): \(_message)"
                } else {
                    message = _title
                }
            } else {
                message = _message
            }
            
            self.init(
                title: title,
                message: message,
                actions: actions,
                completionHandler: completionHandler
            )
        case .unlocalized(let _title, let _message, let actions):
            let message: String
            if let _title {
                if !_message.isEmpty {
                    message = "\(_title): \(_message)"
                } else {
                    message = _title
                }
            } else {
                message = _message
            }
            
            self.init(
                title: title,
                message: "\(message)",
                actions: actions,
                completionHandler: completionHandler
            )
        }
    }
    
    
    fileprivate static func parse(error: Error) -> ParsedError {
#if canImport(ErrorManager)
        if let error = error as? ErrorManager {
            return .unlocalized(
                title: error.errorDescription ?? error.description,
                message: error.errorDescription == nil ? (error.failureReason ?? error.recoverySuggestion ?? "") : (error.failureReason ?? error.recoverySuggestion ?? error.description ?? ""),
                actions: []
            )
        }
#endif
        
        if let error = error as? AlertManager {
            return .localized(
                title: error.titleResource,
                message: error.messageResource,
                actions: error.actions
            )
        } else if let localizableError = error as? (any LocalizableError) {
            return .localized(
                title: localizableError.titleResource,
                message: localizableError.messageResource,
                actions: localizableError.actions()
            )
        } else if let genericError = error as? any GenericError {
            return .unlocalized(
                title: genericError.title,
                message: genericError.message,
                actions: []
            )
        } else if let localizedError = error as? LocalizedError {
            return .unlocalized(
                title: localizedError.errorDescription ?? String(describing: localizedError),
                message: localizedError.failureReason ?? localizedError.recoverySuggestion ?? "",
                actions: []
            )
        } else {
            let error = error as NSError
            if error.localizedDescription.hasPrefix("The operation couldn’t be completed.") {
                return .unlocalized(
                    title: error.description,
                    message: "",
                    actions: []
                )
            } else {
                return .unlocalized(
                    title: error.localizedDescription,
                    message: error.localizedFailureReason ?? error.localizedRecoverySuggestion ?? "",
                    actions: []
                )
            }
        }
    }
    
    fileprivate enum ParsedError {
        case localized(title: LocalizedStringResource?, message: LocalizedStringResource, actions: [AlertAction])
        case unlocalized(title: String?, message: String, actions: [AlertAction])
    }
    
}
