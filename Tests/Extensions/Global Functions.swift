//
//  Global Functions.swift
//  Essentials
//
//  Created by Vaida on 4/8/25.
//

import Testing
@testable
import Essentials


@Suite
struct GlobalFunctions {
    
    @Test func clampTests() {
        #expect(clamp(0) == 0)
        #expect(clamp(0, min: 1) == 1)
        #expect(clamp(0, min: 1, max: 2) == 1)
        #expect(clamp(3, min: 1, max: 2) == 2)
        #expect(clamp(1.5, min: 1, max: 2) == 1.5)
    }
    
    @Test func linearInterpolate() async throws {
        #expect(Essentials.linearInterpolate(1) == 1)
        #expect(Essentials.linearInterpolate(1, in: 0...2) == 0.5)
        #expect(Essentials.linearInterpolate(1, in: 0...2, to: 3...5) == 4)
    }
    
    @Test func captureStdout() async throws {
        let handle = withStandardOutputCaptured {
            print("123", terminator: "")
        }
        let value = try String(data: handle.readToEnd()!, encoding: .utf8)
        #expect(value == "123")
    }
    
    @Test func asyncCaptureStdout() async throws {
        let handle = await withStandardOutputAsyncCaptured {
            print("123", terminator: "")
        }
        let value = try String(data: handle.readToEnd()!, encoding: .utf8)
        #expect(value == "123")
    }
    
}
