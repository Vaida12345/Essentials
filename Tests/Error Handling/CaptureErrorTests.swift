//
//  CaptureErrorTests.swift
//  Essentials
//
//  Created by Vaida on 2025-09-09.
//

import Testing
import Essentials


@Suite("CaptureErrorTests")
struct CaptureErrorTests {
    
    @Test nonisolated func mainActorCallMainActor() {
        @MainActor func closure() async -> Void {
            MainActor.assertIsolated("")
        }
        
        Task { @MainActor in
            MainActor.assertIsolated("")
            await withErrorPresented("123") {
                await closure()
            }
        }
    }
    
    @Test nonisolated func globalActorCallMainActor() {
        @MainActor func closure() async -> Void {
            MainActor.assertIsolated("")
        }
        
        Task {
            await withErrorPresented("123") {
                await closure()
            }
        }
    }
    
    @Test nonisolated func mainActorCallGlobalActor() {
        nonisolated(nonsending) func closure() async -> Void {
            MainActor.assertIsolated("")
        }
        
        Task { @MainActor in
            MainActor.assertIsolated("")
            await withErrorPresented("123") {
                await closure()
            }
        }
    }
    
}
