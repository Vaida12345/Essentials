//
//  Array + vDSP.swift
//  Essentials
//
//  Created by Vaida on 2025-06-09.
//

import Essentials
import Testing

@Suite
struct Array_vDSP {
    
    @Test
    func stride() async throws {
        #expect(Array<Float>.stride(from: 0, by: 1, count: 10) == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        #expect(Array<Float>.stride(from: 0, through: 10, count: 11) == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        
        #expect(Array<Double>.stride(from: 0, by: 1, count: 10) == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        #expect(Array<Double>.stride(from: 0, through: 10, count: 11) == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    }
    
}
