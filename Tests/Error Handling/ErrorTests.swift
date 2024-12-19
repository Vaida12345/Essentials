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
            #expect("\(error)" == "TestError: error!")
        }
    }
    
    @Test func alertManager() async throws {
        do {
            throw TestError()
        } catch {
            let manager = AlertManager(error)
            #expect(manager.titleResource.key == "TestError")
            #expect(manager.message == "error!")
        }
    }
    
    struct TestError: GenericError {
        var message: String {
            "error!"
        }
    }
}
