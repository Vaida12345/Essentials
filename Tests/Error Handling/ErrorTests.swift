//
//  ErrorTests.swift
//  Essentials
//
//  Created by Vaida on 12/20/24.
//

import Testing
import Essentials


@Suite
struct ErrorTests {
    
    @Test func genericError() async throws {
        do {
            throw TestError()
        } catch {
            #expect("\(error)" == "error!")
            
            let expected = """
                error!
                 ╰─some detail
                    ╰─line 2
                """
            #expect(String(reflecting: error) == expected)
        }
    }
    
    @Test func alertManager() async throws {
        do {
            throw TestError()
        } catch {
            let manager = AlertManager("", error: error)
            #expect(manager.titleResource.key == "")
            #expect(manager.message == "error!")
        }
    }
    
    struct TestError: GenericError {
        var message: String {
            "error!"
        }
        
        var details: String? {
            """
            some detail
             ╰─line 2
            """
        }
    }
}
