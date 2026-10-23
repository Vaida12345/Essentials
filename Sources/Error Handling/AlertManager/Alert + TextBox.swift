//
//  Alert + TextBox.swift
//  Essentials
//
//  Created by Vaida on 2026-10-23.
//

import Foundation


@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension AlertManager {
    
    @usableFromInline
    internal enum TextBox: Sendable, Equatable {
        case localized(LocalizedStringResource)
        case raw(String)
        
        @inlinable
        func bestLocalized() -> String {
            switch self {
            case .localized(let localized):
                return String(localized: localized)
            case .raw(let string):
                return string
            }
        }
    }
    
}
