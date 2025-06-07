//
//  NS Ex.swift
//  Essentials
//
//  Created by Vaida on 2025-06-07.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
import Testing
import Essentials

@Suite
struct NextStepTests {
    @Test func color() async throws {
        #expect(NSColor.white.hexDescription == "ffffff")
    }
}


#endif
