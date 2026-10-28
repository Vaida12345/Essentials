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
/// When presenting an error, the title identifies the failed task or outcome, while the message explains the underlying error.
///
/// - Warning: Please note that `AlertManager` does not support attributed strings.
///
/// - Note: The AlertManager itself conforms to `Error`, which means it could be thrown. However, ``LocalizableError`` is better suited for situations like this.
///
/// ## Topics
///
/// ### Creates a manager
///
/// - ``init(_:error:completionHandler:)``
/// - ``init(_:message:completionHandler:)``
/// - ``init(_:message:actions:completionHandler:)``
///
///
/// ### Show alert
///
/// - ``present()``
///
///
/// ### Actions
///
/// - ``appendingAction(title:isDestructive:handler:)``
/// - ``AlertAction``
///
///
/// ### Handlers
///
/// - ``withErrorPresented(_:body:completionHandler:)-(_,()->T,_)``
/// - ``withErrorPresented(_:body:completionHandler:)-(_,,_)``
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public struct AlertManager: GenericError, CustomStringConvertible, Equatable, Sendable {
    
    /// The title that identifies the task or outcome presented by this alert.
    public let titleResource: LocalizedStringResource
    
    /// The message that explains the underlying error or other alert detail.
    @usableFromInline
    internal let messageResource: TextBox
    
    internal let actions: [AlertAction]
    
    internal let completionHandler: (@MainActor @Sendable () -> Void)?
    
    /// A description suitable for generic audience.
    @inlinable
    public var description: String {
        let title = String(localized: titleResource)
        let message = messageResource.bestLocalized()
        
        return if !title.isEmpty {
            "\(title): \(message)"
        } else {
            message
        }
    }
    
    @inlinable
    public var errorDescription: String? {
        self.messageResource.bestLocalized()
    }
    
    @inlinable
    public var failureReason: String? {
        self.messageResource.bestLocalized()
    }
    
    @inlinable
    public var message: String {
        self.messageResource.bestLocalized()
    }
    
    @inlinable
    public var localizedDescription: String {
        self.messageResource.bestLocalized()
    }
    
    internal init(title: LocalizedStringResource, message: TextBox, actions: [AlertAction], completionHandler: (@MainActor @Sendable () -> Void)?) {
        self.titleResource = title
        self.messageResource = message
        self.actions = actions
        self.completionHandler = completionHandler
    }
    
    /// Append an attached action.
    ///
    /// - Parameters:
    ///   - title: The action title.
    ///   - isDestructive: Whether the action has a destructive effect.
    ///   - handler: A block to execute when the user selects the action.
    public func appendingAction(title: LocalizedStringResource, isDestructive: Bool = false, handler: @MainActor @escaping () -> Void) -> AlertManager {
        AlertManager(
            title: self.titleResource,
            message: self.messageResource,
            actions: self.actions + [AlertAction(title: title, isDestructive: isDestructive, handler: handler)],
            completionHandler: self.completionHandler
        )
    }
    
    
    /// Creates an alert manager with the messages to display.
    ///
    /// - Parameters:
    ///   - title: The title that identifies the task or outcome presented by this alert.
    ///   - message: The message that explains the underlying error or other alert detail.
    @available(*, deprecated, renamed: "init(_:message:)")
    public init(title: LocalizedStringResource, message: LocalizedStringResource) {
        self.init(title: title, message: .localized(message), actions: [], completionHandler: nil)
    }
    
    /// Creates an alert manager with the messages to display, and the optional actions
    ///
    /// - Parameters:
    ///   - title: The title that identifies the task or outcome presented by this alert.
    ///   - message: The message that explains the underlying error or other alert detail.
    ///   - actions: The optional actions for the displaying error. The first action is considered the default action, and user can invoke this button by pressing the Return key.
    @available(*, deprecated, renamed: "init(_:message:actions:)")
    public init(title: LocalizedStringResource, message: LocalizedStringResource, @AlertAction.Builder actions: () -> [AlertAction]) {
        self.init(title: title, message: .localized(message), actions: actions(), completionHandler: nil)
    }
    
    /// Creates an alert manager with the messages to display.
    ///
    /// - Parameters:
    ///   - title: The title that identifies the task or outcome presented by this alert.
    ///   - message: The message that explains the underlying error or other alert detail.
    ///   - completionHandler: the handler that is called when the user dismisses the alert. It is called after alert action.
    public init(_ title: LocalizedStringResource, message: LocalizedStringResource, completionHandler: (@MainActor @Sendable () -> Void)? = nil) {
        self.init(title: title, message: .localized(message), actions: [], completionHandler: completionHandler)
    }
    
    /// Creates an alert manager with the messages to display, and the optional actions
    ///
    /// - Parameters:
    ///   - title: The title that identifies the task or outcome presented by this alert.
    ///   - message: The message that explains the underlying error or other alert detail.
    ///   - actions: The optional actions for the displaying error. The first action is considered the default action, and user can invoke this button by pressing the Return key.
    ///   - completionHandler: the handler that is called when the user dismisses the alert. It is called after alert action.
    public init(_ title: LocalizedStringResource, message: LocalizedStringResource, @AlertAction.Builder actions: () -> [AlertAction], completionHandler: (@MainActor @Sendable () -> Void)? = nil) {
        self.init(title: title, message: .localized(message), actions: actions(), completionHandler: completionHandler)
    }
    
    public static func == (_ lhs: AlertManager, _ rhs: AlertManager) -> Bool {
        lhs.titleResource == rhs.titleResource &&
        lhs.messageResource == rhs.messageResource &&
        lhs.actions == rhs.actions
    }
    
}
