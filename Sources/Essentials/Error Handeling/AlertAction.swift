//
//  AlertAction.swift
//  The Essentials Module
//
//  Created by Vaida on 2023/11/12.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation
#if canImport(AppKit)
import AppKit
#endif


/// An action attached to an ``AlertManager``.
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public struct AlertAction: Equatable {
    
    /// The title of the action
    internal let title: LocalizedStringResource
    
    internal let isDestructive: Bool
    
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    internal let handler: _Action
    
    internal let selector: Selector
#elseif canImport(UIKit)
    internal let handler: () -> Void
#endif
    
    
    /// Creates an attached action.
    ///
    /// - Parameters:
    ///   - title: The action title.
    ///   - isDestructive: Whether the action has a destructive effect.
    ///   - handler: A block to execute when the user selects the action.
    public init(title: LocalizedStringResource, isDestructive: Bool = false, handler: @escaping () -> Void) {
        self.title = title
        self.isDestructive = isDestructive
        
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        let handler = {
            handler()
            Task { @MainActor in
                NSApplication.shared.stopModal()
            }
        }
        self.handler = _Action(action: handler)
        self.selector = #selector(self.handler.action)
#elseif canImport(UIKit)
        self.handler = handler
#endif
    }
    
    /// Creates an attached action.
    ///
    /// - Parameters:
    ///   - title: The action title.
    ///   - isDestructive: Whether the action has a destructive effect.
    public init(title: LocalizedStringResource, isDestructive: Bool = false) {
        self.title = title
        self.isDestructive = isDestructive
        
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        let handler = {
            Task { @MainActor in
                NSApplication.shared.stopModal()
            }
            return
        }
        self.handler = _Action(action: handler)
        self.selector = #selector(self.handler.action)
#elseif canImport(UIKit)
        self.handler = {}
#endif
    }
    
    
    
    public static func == (lhs: AlertAction, rhs: AlertAction) -> Bool {
        lhs.title == rhs.title && lhs.isDestructive == rhs.isDestructive
    }
    
    internal final class _Action: NSObject {
        
        internal let _action: () -> Void
        
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        internal weak var parent: NSAlert?
#endif
        
        internal init(action: @escaping () -> Void) {
            _action = action
            super.init()
        }
        
        @MainActor @objc internal func action() {
            _action()
            
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
            guard let parent else { return }
            NSApp.endSheet(parent.window)
#endif
        }
    }
    
    /// The `resultBuilder` that converts a list of `Actions` expressions to array.
    @resultBuilder
    public enum Builder {
        public static func buildBlock(_ components: AlertAction...) -> [AlertAction] {
            components
        }
    }
}
