//
//  withErrorPresented.swift
//  Essentials
//
//  Created by Vaida on 2026-09-03.
//

import Foundation


/// Runs the `body`, and present error using ``AlertManager`` if any.
@available(*, deprecated, renamed: "withErrorPresented(_:body:completionHandler:)", message: "")
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
@available(*, deprecated, renamed: "withErrorPresented(_:body:completionHandler:)", message: "")
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public func withErrorPresented<T>(_ body: () throws -> T) -> T? {
    withErrorPresented("") {
        try body()
    }
}


@inlinable
@discardableResult
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@available(*, deprecated, renamed: "withErrorPresented(_:body:completionHandler:)", message: "")
public nonisolated(nonsending) func withErrorPresented<T>(
    _ title: LocalizedStringResource,
    body: nonisolated(nonsending) () async throws -> T,
    errorHandler: @escaping @Sendable () -> Void
) async -> T? {
    await withErrorPresented(title, body: body, completionHandler: errorHandler)
}


@inlinable
@discardableResult
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
@available(*, deprecated, renamed: "withErrorPresented(_:body:completionHandler:)", message: "")
public func withErrorPresented<T>(
    _ title: LocalizedStringResource,
    body: () throws -> T,
    errorHandler: @escaping @Sendable () -> Void
) -> T? {
    withErrorPresented(title, body: body, completionHandler: errorHandler)
}


/// Runs the `body`, and present error using ``AlertManager`` if any.
///
/// - Parameters:
///   - title: The title for the error. This is recommended so the user would understand the implication of such error.
///   - body: The main body.
///   - completionHandler: the handler that is called when the user dismisses the alert. It is called after alert action.
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
    completionHandler: (@Sendable () -> Void)? = nil
) async -> T? {
    do {
        return try await body()
    } catch {
        AlertManager(title, error: error, completionHandler: completionHandler).present()
    }
    return nil
}

/// Runs the `body`, and present error using ``AlertManager`` if any.
///
/// - Parameters:
///   - title: The title for the error. This is recommended so the user would understand the implication of such error.
///   - body: The main body.
///   - completionHandler: the handler that is called when the user dismisses the alert. It is called after alert action.
@inlinable
@discardableResult
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public func withErrorPresented<T>(
    _ title: LocalizedStringResource,
    body: () throws -> T,
    completionHandler: (@Sendable () -> Void)? = nil
) -> T? {
    do {
        return try body()
    } catch {
        AlertManager(title, error: error, completionHandler: completionHandler).present()
    }
    return nil
}
