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
/// - Note: The AlertManager itself conforms to `Error`, which means it could be thrown and initialized again using ``AlertManager/init(_:)``.
///
/// ## Topics
///
/// ### Creates a manager
///
/// - ``init(_:)``
/// - ``init(_:message:)``
/// - ``init(_:message:actions:)``
///
///
/// ### Show alert
///
/// - ``present()``
/// - ``present(_:)``
/// - ``present(title:message:)``
///
///
/// ### Actions
///
/// - ``present(title:message:actions:)``
/// - ``appendAction(title:isDestructive:handler:)``
/// - ``appendingAction(title:isDestructive:handler:)``
/// - ``AlertAction``
///
///
/// ### Handlers
///
/// - ``withErrorPresented(_:body:)-48tr1``
/// - ``withErrorPresented(_:body:)-6xgyj``
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
    @available(*, deprecated, renamed: "init(_:message:actions:)", message: "Use the new interface instead")
    public init(title: LocalizedStringResource, message: LocalizedStringResource, @AlertAction.Builder actions: () -> [AlertAction]) {
        self.init(title: title, message: message, actions: actions())
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
    ///
    /// - SeeAlso: You can also use the following functions to present the captured error: ``withErrorPresented(_:)-9tpp3``, ``withErrorPresented(_:)-6jpcn``.
    public init(_ error: some Error) {
        #if canImport(ErrorManager)
        if let error = error as? ErrorManager {
            self.init(title: LocalizedStringResource(stringLiteral: error.errorDescription ?? error.description), message: LocalizedStringResource(stringLiteral: error.errorDescription == nil ? (error.failureReason ?? error.recoverySuggestion ?? "") : (error.failureReason ?? error.recoverySuggestion ?? error.description ?? "")))
        }
        #endif
        
        if let error = error as? AlertManager {
            self = error
        } else if let localizableError = error as? (any LocalizableError) {
            self.init(title: localizableError.titleResource, message: localizableError.messageResource, actions: [])
        } else if let errorManager = error as? any GenericError {
            self.init(title: LocalizedStringResource(stringLiteral: errorManager.title),
                      message: LocalizedStringResource(stringLiteral: errorManager.message),
                      actions: [])
        } else if let localizedError = error as? LocalizedError {
            self.init(title: LocalizedStringResource(stringLiteral: localizedError.errorDescription ?? String(describing: localizedError)),
                      message: LocalizedStringResource(stringLiteral: localizedError.failureReason ?? localizedError.recoverySuggestion ?? ""),
                      actions: [])
        } else {
            let error = error as NSError
            self.init(title: LocalizedStringResource(stringLiteral: error.localizedDescription),
                      message: LocalizedStringResource(stringLiteral: ""),
                      actions: [])
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
    
    
    /// Present the given error.
    ///
    /// - SeeAlso: You can also use the following functions to present the captured error: ``withErrorPresented(_:)-9tpp3``, ``withErrorPresented(_:)-6jpcn``.
    public static func present(_ error: some Error) {
        AlertManager(error).present()
    }
    
    /// Present the error with `title` and `message`.
    ///
    /// - Parameters:
    ///   - title: The title of displaying error.
    ///   - message: The message of displaying error.
    public static func present(title: LocalizedStringResource, message: LocalizedStringResource) {
        AlertManager(title: title, message: message, actions: []).present()
    }
    
    /// Present the error with `title`, `message`, and `actions`.
    ///
    /// - Parameters:
    ///   - title: The title of displaying error.
    ///   - message: The message of displaying error.
    ///   - actions: The optional actions for the displaying error. The first action is considered the default action, and user can invoke this button by pressing the Return key.
    public static func present(title: LocalizedStringResource, message: LocalizedStringResource, @AlertAction.Builder actions: () -> [AlertAction]) {
        AlertManager(title: title, message: message, actions: actions()).present()
    }
    
}


/// Runs the `body`, and present error using ``AlertManager`` if any.
@available(*, deprecated, renamed: "withErrorPresented(_:body:)", message: "")
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@inlinable
public func withErrorPresented(_ body: @escaping @Sendable () async throws -> Void) async {
    do {
        try await body()
    } catch {
        AlertManager(error).present()
    }
}

/// Runs the `body`, and present error using ``AlertManager`` if any.
///
/// - Parameters:
///   - title: The title for the error. This is recommended so the user would understand the implication of such error.
///   - body: The main body.
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public func withErrorPresented<T>(
    _ title: String,
    body: @Sendable () async throws -> T,
    onSuccess: (T) async -> Void = {_ in }
) async {
    do {
        let content = try await body()
        await onSuccess(content)
    } catch {
        let manager = AlertManager(error)
        AlertManager(title: LocalizedStringResource(stringLiteral: title), message: LocalizedStringResource(stringLiteral: manager.description), actions: manager.actions).present()
    }
}


/// Runs the `body`, and present error using ``AlertManager`` if any.
@inlinable
@discardableResult
@available(*, deprecated, renamed: "withErrorPresented(_:body:)", message: "")
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public func withErrorPresented<T>(_ body: () throws -> T) -> T? {
    do {
        return try body()
    } catch {
        AlertManager(error).present()
    }
    return nil
}


/// Runs the `body`, and present error using ``AlertManager`` if any.
///
/// - Parameters:
///   - title: The title for the error. This is recommended so the user would understand the implication of such error.
///   - body: The main body.
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public func withErrorPresented<T>(
    _ title: String,
    body: () throws -> T,
    onSuccess: (T) -> Void = {_ in }
) {
    do {
        let content = try body()
        onSuccess(content)
    } catch {
        let manager = AlertManager(error)
        AlertManager(title: LocalizedStringResource(stringLiteral: title), message: LocalizedStringResource(stringLiteral: manager.description), actions: manager.actions).present()
    }
}
