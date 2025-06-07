//
//  withTimeLimit.swift
//  Essentials
//
//  Created by Vaida on 1/4/25.
//


@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Task where Success == Never, Failure == Never {
    
    /// Apply the time limit to `operation`.
    ///
    /// In the following example, it would print "cancelled", and throw ``TimeoutError``.
    ///
    /// ```swift
    ///try await Task.withTimeLimit(for: .seconds(3)) {
    ///     try await withTaskCancellationHandler {
    ///         try await Task.sleep(for: .seconds(5))
    ///         print("done")
    ///     } onCancel: {
    ///         print("cancelled")
    ///     }
    /// }
    /// ```
    ///
    /// - Note: At the end of the time limit, a task cancelation will be sent to `operation`, and it is your responsibility to check for cancelation, and stop the operation accordingly.
    ///
    /// - throws: ``TimeoutError``.
    ///
    /// ## Topics
    /// ### Error Type
    /// - ``TimeoutError``
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    public static func withTimeLimit<T>(
        for duration: Duration,
        priority: TaskPriority? = nil,
        operation: @Sendable @escaping () async throws -> T
    ) async throws -> T where T: Sendable {
        try await withThrowingTaskGroup(of: T.self) { taskGroup in
            taskGroup.addTask(priority: priority, operation: operation)
            taskGroup.addTask {
                try await Task.sleep(for: duration)
                throw TimeoutError(duration: duration)
            }
            for try await value in taskGroup {
                taskGroup.cancelAll()
                return value
            }
            fatalError("Should never reach here")
        }
    }
    
}

/// The operation has timed out.
///
/// This error is thrown by ``_Concurrency/Task/withTimeLimit(for:operation:)``.
///
/// In the following example, it would print "cancelled", and throw ``TimeoutError``, with ``duration`` of 3 sec.
///
/// ```swift
///try await Task.withTimeLimit(for: .seconds(3)) {
///     try await withTaskCancellationHandler {
///         try await Task.sleep(for: .seconds(5))
///         print("done")
///     } onCancel: {
///         print("cancelled")
///     }
/// }
/// ```
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public struct TimeoutError: GenericError {
    
    /// The duration for which the task has been executing.
    ///
    /// This value is the same as the `duration` parameter for ``_Concurrency/Task/withTimeLimit(for:operation:)``.
    public let duration: Duration
    
    
    fileprivate init(duration: Duration) {
        self.duration = duration
    }
    
    @inlinable
    public var title: String? {
        "Operation time out"
    }
    
    @inlinable
    public var message: String {
        "The operation time out (\(self.duration.seconds, format: .timeInterval))"
    }
    
}
