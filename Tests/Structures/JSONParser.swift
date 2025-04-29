//
//  JSONParser.swift
//  Essentials
//
//  Created by Vaida on 4/29/25.
//

import Testing
@testable import Essentials

@Suite
struct JSONParser {
    @Test func parserInt() async throws {
        let parser = try Essentials.JSONParser(string: #"{"a": 1}"#)
        try #expect(parser["a", .integer] == Int(1))
    }
}
