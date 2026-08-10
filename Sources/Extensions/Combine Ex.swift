//
//  Combine Ex.swift
//  Essentials
//
//  Created by Vaida on 2026-08-10.
//

import Combine
import Foundation


extension Optional where Wrapped: NSObject {
    
    /// Returns a publisher that emits changes to the specified key path when this optional contains an object.
    ///
    /// This is useful when observing KVO-compliant properties on an optional object while still requiring a non-optional publisher, such as when using SwiftUI's `onReceive`.
    ///
    /// ```swift
    /// .onReceive(progress.publisher(for: \.totalUnitCount)) {
    ///     self.totalUnitCount = $0
    /// }
    /// ```
    ///
    /// - Parameter keyPath: The key path of the property to observe.
    ///
    /// - Returns: A type-erased publisher that emits values from the observed property, or an empty publisher when this optional is `nil`.
    public func publisher<Value>(for keyPath: KeyPath<Wrapped, Value>) -> AnyPublisher<Value, Never> {
        guard let wrapped = self else {
            return Empty().eraseToAnyPublisher()
        }
        
        return wrapped.publisher(for: keyPath).eraseToAnyPublisher()
    }
}
