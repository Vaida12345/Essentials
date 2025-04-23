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
        
        #expect(clamp(-1, min: 1, max: -1) == 1)
        #expect(clamp(0, min: 1, max: -1) == 1)
        #expect(clamp(1.5, min: 1, max: -1) == -1)
    }
    
}
