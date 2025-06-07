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
            #expect(String(reflecting: error) == "error!\nsome detail")
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
            "some detail"
        }
    }
}
