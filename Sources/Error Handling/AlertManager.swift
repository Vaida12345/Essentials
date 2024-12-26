//
//  AlertManager.swift
//  The Essentials Module
//
//  Created by Vaida on 5/8/22.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#elseif canImport(WatchKit)
import WatchKit
#elseif canImport(UIKit)
import UIKit
#endif
#if canImport(ErrorManager)
import ErrorManager
#endif


/// A manager that could manage the presentation of alerts.
///
/// An alert manager uses pre-SwiftUI technologies, so you can call ``AlertManager/present()`` where ever you want. However, for best practices, one should call this within a `View`.
///
/// ```swift
/// AlertManager(title: "Pause the task?",
///              message: "You can resume later") {
///     AlertAction(title: "Pause") {
///         pause()
///     }
/// }.present()
/// ```
///
/// Using `LocalizedStringResource`, these three `String`s would appear in *Localizable.xcstrings* automatically.
///
/// - Warning: Please note that `AlertManager` does not support attributed strings.
///
/// - Note: The AlertManager itself conforms to `Error`, which means it could be thrown.
///
/// ## Topics
///
/// ### Creates a manager
///
/// - ``init(_:error:)``
/// - ``init(_:message:)``
/// - ``init(_:message:actions:)``
///
///
/// ### Show alert
///
/// - ``present()``
///
///
/// ### Actions
///
/// - ``appendAction(title:isDestructive:handler:)``
/// - ``appendingAction(title:isDestructive:handler:)``
/// - ``AlertAction``
///
///
/// ### Handlers
///
/// - ``withErrorPresented(_:body:)-6t4zi``
/// - ``withErrorPresented(_:body:)-2eqy9``
/// - ``withErrorPresented(_:)-9tpp3``
/// - ``withErrorPresented(_:)-6jpcn``
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public struct AlertManager: LocalizableError {
    
    public let titleResource: LocalizedStringResource
    
    public let messageResource: LocalizedStringResource
    
    nonisolated(unsafe)
    fileprivate var actions: [AlertAction]
    
    
    fileprivate init(title: LocalizedStringResource, message: LocalizedStringResource, actions: [AlertAction]) {
        self.titleResource = title
        self.messageResource = message
        self.actions = actions
    }
    
    /// Append an attached action.
    ///
    /// - Parameters:
    ///   - title: The action title.
    ///   - isDestructive: Whether the action has a destructive effect.
    ///   - handler: A block to execute when the user selects the action.
    public mutating func appendAction(title: LocalizedStringResource, isDestructive: Bool = false, handler: @escaping () -> Void) {
        self.actions.append(AlertAction(title: title, isDestructive: isDestructive, handler: handler))
    }
    
    /// Append an attached action.
    ///
    /// - Parameters:
    ///   - title: The action title.
    ///   - isDestructive: Whether the action has a destructive effect.
    ///   - handler: A block to execute when the user selects the action.
    public func appendingAction(title: LocalizedStringResource, isDestructive: Bool = false, handler: @escaping () -> Void) -> AlertManager {
        AlertManager(title: self.titleResource, message: self.messageResource, actions: self.actions + [AlertAction(title: title, isDestructive: isDestructive, handler: handler)])
    }
    
    
    /// Creates an alert manager with the messages to display.
    ///
    /// - Parameters:
    ///   - title: The title of displaying error.
    ///   - message: The message of displaying error.
    @available(*, deprecated, renamed: "init(_:message:)", message: "Use the new interface instead")
    public init(title: LocalizedStringResource, message: LocalizedStringResource) {
        self.init(title: title, message: message, actions: [])
    }
    
    /// Creates an alert manager with the messages to display, and the optional actions
    ///
    /// - Parameters:
    ///   - title: The title of displaying error.
    ///   - message: The message of displaying error.
    ///   - actions: The optional actions for the displaying error. The first action is considered the default action, and user can invoke this button by pressing the Return key.
    @available(*, deprecated, renamed: "init(_:message:actions:)", message: "Use the new interface instead")
    public init(title: LocalizedStringResource, message: LocalizedStringResource, @AlertAction.Builder actions: () -> [AlertAction]) {
        self.init(title: title, message: message, actions: actions())
    }
    
    /// Creates an alert manager with the messages to display.
    ///
    /// - Parameters:
    ///   - title: The title of displaying error.
    ///   - message: The message of displaying error.
    public init(_ title: LocalizedStringResource, message: LocalizedStringResource) {
        self.init(title: title, message: message, actions: [])
    }
    
    /// Creates an alert manager with the messages to display, and the optional actions
    ///
    /// - Parameters:
    ///   - title: The title of displaying error.
    ///   - message: The message of displaying error.
    ///   - actions: The optional actions for the displaying error. The first action is considered the default action, and user can invoke this button by pressing the Return key.
    public init(_ title: LocalizedStringResource, message: LocalizedStringResource, @AlertAction.Builder actions: () -> [AlertAction]) {
        self.init(title: title, message: message, actions: actions())
    }
    
    /// Creates an alert manager with a given error.
    @available(*, unavailable, message: "Please use `init(_:error:)` instead")
    public init(_ error: some Error) {
        fatalError()
    }
    
    /// Creates an alert manager with a given error.
    public init(_ title: LocalizedStringResource, error: any Error) {
        let error = AlertManager.parse(error: error)
        switch error {
        case .localized(let _title, let _message, let actions):
            let message: LocalizedStringResource
            if let _title {
                message = "\(_title): \(_message)"
            } else {
                message = _message
            }
            
            self.init(
                title: title,
                message: message,
                actions: actions
            )
        case .unlocalized(let _title, let _message, let actions):
            let message: String
            if let _title {
                message = "\(_title): \(_message)"
            } else {
                message = _message
            }
            
            self.init(
                title: title,
                message: "\(message)",
                actions: actions
            )
        }
    }
    
    
    /// Presents the alert.
    public func present() {
        Task { @MainActor in
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
            let alert = NSAlert()
            alert.informativeText = self.messageResource.localized()
            alert.messageText = self.titleResource.localized()
            
            if !self.actions.isEmpty {
                for i in 0..<actions.count {
                    let action = self.actions[i]
                    let button = alert.addButton(withTitle: action.title.localized())
                    action.handler.parent = alert
                    
                    if action.title.key == "Cancel" {
                        button.keyEquivalent = "\u{1b}"
                    }
                    
                    button.hasDestructiveAction = action.isDestructive
                    button.action = action.selector
                    button.target = action.handler
                }
            }
            
            alert.runModal()
#elseif canImport(UIKit) && !os(watchOS)
            let controller = UIAlertController(title: self.titleResource.localized(), message: self.messageResource.localized(), preferredStyle: .alert)
            for action in actions {
                let title = action.title.localized()
                let style =
                if action.title.key == "Cancel" {
                    UIAlertAction.Style.cancel
                } else {
                    action.isDestructive ? UIAlertAction.Style.destructive : .default
                }
                let alertAction = UIAlertAction(title: title, style: style, handler: { _ in action.handler() })
                controller.addAction(alertAction)
            }
            
            if controller.actions.isEmpty {
                // set default action
                controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            }
            
            controller.preferredAction = controller.actions.first
            let rootController = UIApplication
                .shared
                .connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .last?
                .rootViewController
            
            (rootController?.presentedViewController ?? rootController)?.present(controller, animated: true, completion: nil)
#elseif os(watchOS)
            
            guard let viewController = (WKApplication.shared().visibleInterfaceController ?? WKApplication.shared().rootInterfaceController) else { return }
            
            var actions = self.actions.map { action in
                WKAlertAction(title: action.title.localized(), style: (action.title.key == "Cancel" ? .cancel : (action.isDestructive ? .destructive : .default)), handler: action.handler)
            }
            if actions.isEmpty {
                actions.append(WKAlertAction(title: "OK", style: .default, handler: {}))
            }
            
            viewController.presentAlert(withTitle: self.titleResource.localized(),
                                        message: self.messageResource.localized(),
                                        preferredStyle: .alert,
                                        actions: actions)
#endif
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
            return .unlocalized(
                title: error.localizedDescription,
                message: error.localizedFailureReason ?? error.localizedRecoverySuggestion ?? "",
                actions: []
            )
        }
    }
    
    fileprivate enum ParsedError {
        case localized(title: LocalizedStringResource?, message: LocalizedStringResource, actions: [AlertAction])
        case unlocalized(title: String?, message: String, actions: [AlertAction])
    }
    
}


/// Runs the `body`, and present error using ``AlertManager`` if any.
@available(*, deprecated, renamed: "withErrorPresented(_:body:)", message: "")
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@inlinable
public func withErrorPresented(_ body: @escaping @Sendable () async throws -> Void) async {
    await withErrorPresented("") {
        try await body()
    }
}


/// Runs the `body`, and present error using ``AlertManager`` if any.
@inlinable
@discardableResult
@available(*, deprecated, renamed: "withErrorPresented(_:body:)", message: "")
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public func withErrorPresented<T>(_ body: () throws -> T) -> T? {
    withErrorPresented("") {
        try body()
    }
}


/// Runs the `body`, and present error using ``AlertManager`` if any.
///
/// - Parameters:
///   - title: The title for the error. This is recommended so the user would understand the implication of such error.
///   - body: The main body.
@discardableResult
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public func withErrorPresented<T>(
    _ title: LocalizedStringResource,
    body: @Sendable () async throws -> T
) async -> T? {
    do {
        return try await body()
    } catch {
        AlertManager(title, error: error).present()
    }
    return nil
}

/// Runs the `body`, and present error using ``AlertManager`` if any.
///
/// - Parameters:
///   - title: The title for the error. This is recommended so the user would understand the implication of such error.
///   - body: The main body.
@discardableResult
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public func withErrorPresented<T>(
    _ title: LocalizedStringResource,
    body: () throws -> T
) -> T? {
    do {
        return try body()
    } catch {
        AlertManager(title, error: error).present()
    }
    return nil
}
