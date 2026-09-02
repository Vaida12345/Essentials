//
//  Alert + Presentation.swift
//  Essentials
//
//  Created by Vaida on 2026-09-03.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#elseif canImport(WatchKit)
import WatchKit
#elseif canImport(UIKit)
import UIKit
#endif


#if canImport(AppKit) && !targetEnvironment(macCatalyst)
@available(macOS 13.0, *)
private final class RetainingAlert: NSAlert {
    var actionOwners: [AlertAction._Action] = []
}
#endif


@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension AlertManager {
    
    /// Presents the alert.
    public func present() {
        Task { @MainActor in
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
            let alert = RetainingAlert()
            alert.informativeText = self.messageResource.localized()
            alert.messageText = self.titleResource.localized()
            
            var actions = self.actions
            if actions.isEmpty, let completionHandler {
                actions.append(AlertAction(title: "OK")) // must have a default action, so it can call `completionHandler`.
            } // otherwise, macOS will add a default action for NSAlert.
            
            if !actions.isEmpty {
                for i in 0..<actions.count {
                    let action = actions[i]
                    let button = alert.addButton(withTitle: action.title.localized())
                    
                    let (owner, selector) = action.makeAction(manager: self)
                    
                    owner.parent = alert
                    alert.actionOwners.append(owner)
                    
                    if action.title.key == "Cancel" {
                        button.keyEquivalent = "\u{1b}"
                    }
                    
                    button.hasDestructiveAction = action.isDestructive
                    button.action = selector
                    button.target = owner
                }
            }
            
            alert.runModal()
#elseif canImport(UIKit) && !os(watchOS)
            AlertPresentationCoordinator.shared.enqueue(self)
#elseif os(watchOS)
            
            guard let viewController = (WKApplication.shared().visibleInterfaceController ?? WKApplication.shared().rootInterfaceController) else { return }
            
            var actions = self.actions.map { action in
                WKAlertAction(
                    title: action.title.localized(),
                    style: (action.title.key == "Cancel" ? .cancel : (action.isDestructive ? .destructive : .default)),
                    handler: { [completionHandler = self.completionHandler] in
                        action.handler(); completionHandler?()
                    })
            }
            if actions.isEmpty {
                actions.append(
                    WKAlertAction(
                        title: "OK",
                        style: .default,
                        handler: { [completionHandler = self.completionHandler] in
                            completionHandler?()
                        })
                )
            }
            
            viewController.presentAlert(
                withTitle: self.titleResource.localized(),
                message: self.messageResource.localized(),
                preferredStyle: .alert,
                actions: actions)
#endif
        }
    }
    
}



#if canImport(UIKit) && !os(watchOS)
/// An alert controller that notifies its coordinator after it is no longer visible.
@available(iOS 16.0, tvOS 16.0, *)
@MainActor
private final class ManagedAlertController: UIAlertController {
    var onDismiss: (() -> Void)?
    
    private var didNotifyDismissal = false
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        guard !didNotifyDismissal else { return }
        didNotifyDismissal = true
        onDismiss?()
    }
}


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
        
        let controller = ManagedAlertController(
            title: alert.titleResource.localized(),
            message: alert.messageResource.localized(),
            preferredStyle: .alert
        )
        controller.onDismiss = { [weak self, completionHandler = alert.completionHandler] in
            self?.finishPresentation()
            completionHandler?()
        }
        
        for action in alert.actions {
            let style: UIAlertAction.Style = action.title.key == "Cancel" ? .cancel : (action.isDestructive ? .destructive : .default)
            
            controller.addAction(UIAlertAction(title: action.title.localized(), style: style) { _ in
                action.handler()
            })
        }
        
        if controller.actions.isEmpty {
            controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in })
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
