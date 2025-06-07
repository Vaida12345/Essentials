//
//  JSONParser.swift
//  Essentials
//
//  Created by Vaida on 4/29/25.
//

import Testing
import Essentials

@Suite
struct JSONParserTests {
    @Test func parserInt() async throws {
        let parser = try Essentials.JSONParser(string: #"{"a": 1}"#)
        try #expect(parser["a", .integer] == Int(1))
        let b: Int = try parser.value(for: "a")
        #expect(b == 1)
        
        #expect(throws: Essentials.JSONParser.ParserError.self) {
            try print(parser.array("a", type: .numeric))
        }
    }
}
