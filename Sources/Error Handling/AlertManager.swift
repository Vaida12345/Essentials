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
/// - ``withErrorPresented(_:body:errorHandler:)-6tdp``
/// - ``withErrorPresented(_:body:errorHandler:)-3mpqs``
/// - ``withErrorPresented(_:)->_``
/// - ``withErrorPresented(_:)->()``
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public struct AlertManager: LocalizableError, CustomStringConvertible {
    
    public let titleResource: LocalizedStringResource
    
    public let messageResource: LocalizedStringResource
    
    nonisolated(unsafe)
    fileprivate var actions: [AlertAction]
    
    /// A description suitable for generic audience.
    @inlinable
    public var description: String {
        let title = titleResource.localized()
        let message = messageResource.localized()
        
        return if !title.isEmpty {
            "\(title): \(message)"
        } else {
            message
        }
    }
    
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
    @inlinable
    @available(*, unavailable, renamed: "init(_:error:)", message: "Please use `init(_:error:)` instead")
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
                actions: actions
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
            AlertPresentationCoordinator.shared.enqueue(self)
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

#if canImport(UIKit) && !os(watchOS)
/// Serializes UIKit alert presentation so alerts do not race SwiftUI presentation transitions.
@available(iOS 16.0, tvOS 16.0, *)
@MainActor
private final class AlertPresentationCoordinator {
    
    /// The shared coordinator for all UIKit alert requests in the process.
    static let shared = AlertPresentationCoordinator()
    
    private var pendingAlerts: [AlertManager] = []
    private var isPresenting = false
    private var isRetryScheduled = false
    
    /// Adds an alert to the FIFO queue and presents it when UIKit has a stable presenter.
    func enqueue(_ alert: AlertManager) {
        pendingAlerts.append(alert)
        attemptPresentation()
    }
    
    /// Presents the next alert only when no other alert or view-controller transition is active.
    private func attemptPresentation() {
        guard !isPresenting, let alert = pendingAlerts.first else { return }
        guard let presenter = eligiblePresenter() else {
            scheduleRetry()
            return
        }
        
        isPresenting = true
        pendingAlerts.removeFirst()
        
        let controller = UIAlertController(
            title: alert.titleResource.localized(),
            message: alert.messageResource.localized(),
            preferredStyle: .alert
        )
        
        for action in alert.actions {
            let style: UIAlertAction.Style = action.title.key == "Cancel"
            ? .cancel
            : (action.isDestructive ? .destructive : .default)
            controller.addAction(UIAlertAction(title: action.title.localized(), style: style) { [weak self] _ in
                self?.finishPresentation()
                action.handler()
            })
        }
        
        if controller.actions.isEmpty {
            controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { [weak self] _ in
                self?.finishPresentation()
            })
        }
        
        controller.preferredAction = controller.actions.first
        presenter.present(controller, animated: true)
    }
    
    /// Marks the current alert as dismissing and retries once UIKit finishes its dismissal transition.
    private func finishPresentation() {
        isPresenting = false
        scheduleRetry()
    }
    
    /// Delays another presentation attempt, coalescing repeated requests while a transition is active.
    private func scheduleRetry() {
        guard !isRetryScheduled else { return }
        
        isRetryScheduled = true
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 100_000_000)
            guard let self else { return }
            
            isRetryScheduled = false
            attemptPresentation()
        }
    }
    
    /// Returns the top-most controller when it is safe for it to present an alert.
    private func eligiblePresenter() -> UIViewController? {
        guard let rootController = activeWindow?.rootViewController else { return nil }
        
        let presenter = topViewController(from: rootController)
        guard !(presenter is UIAlertController),
              !presenter.isBeingPresented,
              !presenter.isBeingDismissed,
              presenter.transitionCoordinator == nil else {
            return nil
        }
        
        return presenter
    }
    
    /// Finds the visible controller through container and modal presentation hierarchies.
    private func topViewController(from controller: UIViewController) -> UIViewController {
        if let presentedController = controller.presentedViewController {
            return topViewController(from: presentedController)
        }
        if let navigationController = controller as? UINavigationController,
           let visibleController = navigationController.visibleViewController {
            return topViewController(from: visibleController)
        }
        if let tabBarController = controller as? UITabBarController,
           let selectedController = tabBarController.selectedViewController {
            return topViewController(from: selectedController)
        }
        if let splitViewController = controller as? UISplitViewController,
           let visibleController = splitViewController.viewControllers.last {
            return topViewController(from: visibleController)
        }
        
        return controller
    }
    
    /// Locates the key window in a foreground-active application scene.
    private var activeWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first(where: \.isKeyWindow)
    }
}
#endif


/// Runs the `body`, and present error using ``AlertManager`` if any.
@available(*, deprecated, renamed: "withErrorPresented(_:body:)", message: "")
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@inlinable
public nonisolated(nonsending) func withErrorPresented(_ body: nonisolated(nonsending) () async throws -> Void) async {
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
///   - errorHandler: The handler called when the user clicks the default action.
///
/// > Note:
/// > To inherit the actor of the caller, you need to attach the `nonisolated(nonsending)` attribute if you pass a function. See [Swift evolution](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md#nonisolatednonsending-functions).
/// > Closures inherit caller actor by default.
@inlinable
@discardableResult
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public nonisolated(nonsending) func withErrorPresented<T>(
    _ title: LocalizedStringResource,
    body: nonisolated(nonsending) () async throws -> T,
    errorHandler: @escaping () -> Void = {}
) async -> T? {
    do {
        return try await body()
    } catch {
        AlertManager(title, error: error)
            .appendingAction(title: "OK") {
                errorHandler()
            }
            .present()
    }
    return nil
}

/// Runs the `body`, and present error using ``AlertManager`` if any.
///
/// - Parameters:
///   - title: The title for the error. This is recommended so the user would understand the implication of such error.
///   - body: The main body.
///   - errorHandler: The handler called when the user clicks the default action.
@inlinable
@discardableResult
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public func withErrorPresented<T>(
    _ title: LocalizedStringResource,
    body: () throws -> T,
    errorHandler: @escaping () -> Void = {}
) -> T? {
    do {
        return try body()
    } catch {
        AlertManager(title, error: error)
            .appendingAction(title: "OK") {
                errorHandler()
            }
            .present()
    }
    return nil
}
