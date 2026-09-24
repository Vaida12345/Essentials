//
//  ErrorBridgeTests.swift
//  Essentials
//
//  Created by Vaida on 12/20/24.
//

import Testing
import Essentials
import Foundation
import AVFAudio
import AVFoundation


@Suite
struct ErrorBridgeTests {
    
    @Test func genericError() async throws {
        do {
            throw TestError()
        } catch {
            let alert = AlertManager("Operation Failed", error: error)
            #expect(alert.titleResource.key == "Operation Failed")
            #expect(alert.messageResource.key == "<This is the underlying error description>")
        }
    }
    
    struct TestError: GenericError {
        var message: String {
            "<This is the underlying error description>"
        }
    }
    
    @Test func cocoaError() async throws {
        do {
            throw CocoaError(.fileReadCorruptFile)
        } catch {
            let manager = AlertManager("Operation Failed", error: error)
            #expect(manager.titleResource.key == "Operation Failed")
            #expect(manager.message == "The file couldn’t be opened because it isn’t in the correct format.")
        }
    }
    
    @Test func nsError() async throws {
        do {
            throw NSError(domain: AVFoundationErrorDomain, code: Int(kAudioFileUnspecifiedError))
        } catch {
            let manager = AlertManager("Operation Failed", error: error)
            #expect(manager.titleResource.key == "Operation Failed")
            #expect(manager.message == "AVFoundationErrorDomain error 2003334207.")
        }
    }
    
    @Test func fileReadError() async throws {
        let sourceFile = URL.temporaryDirectory.appending(path: "\(UUID()).nonExistingPath")
        
        await confirmation { confirmation in
            do {
                try FileManager.default.copyItem(at: sourceFile, to: sourceFile)
            } catch {
                confirmation()
                let manager = AlertManager("Copying Failed", error: error)
                #expect(manager.titleResource.key == "Copying Failed")
                #expect(manager.message == "The file “\(sourceFile.lastPathComponent)” couldn’t be opened because there is no such file.")
            }
        }
    }
    
    @Test func fileReadUnderlyingError() async throws {
        let sourceFile = URL.temporaryDirectory.appending(path: "\(UUID()).nonExistingPath")
        
        try await confirmation { confirmation in
            do {
                try FileManager.default.copyItem(at: sourceFile, to: sourceFile)
            } catch {
                confirmation()
                let underlyingError = try #require((error as NSError).userInfo["NSUnderlyingError"] as? Error)
                
                let manager = AlertManager("Copying Failed", error: underlyingError)
                #expect(manager.titleResource.key == "Copying Failed")
                #expect(manager.message == "No such file or directory")
            }
        }
    }
    
    @Test func urlError() async throws {
        await confirmation { confirmation in
            do {
                var isStale = false
                let _ = try URL(resolvingBookmarkData: Data(), bookmarkDataIsStale: &isStale)
            } catch {
                confirmation()
                let manager = AlertManager("Open URL failed", error: error)
                #expect(manager.titleResource.key == "Open URL failed")
                #expect(manager.message == "The file couldn’t be opened because it isn’t in the correct format.")
            }
        }
    }
    
    @Test func urlSessionError() async throws {
        let sourceFile = URL.temporaryDirectory.appending(path: "\(UUID()).nonExistingPath")
        
        await confirmation { confirmation in
            do {
                _ = try await URLSession.shared.data(from: sourceFile)
            } catch {
                confirmation()
                let manager = AlertManager("Open URL failed", error: error)
                #expect(manager.titleResource.key == "Open URL failed")
                #expect(manager.message == "The requested URL was not found on this server.")
            }
        }
    }
    
    @Test func decodingError() async throws {
        await confirmation { confirmation in
            do {
                let decoder = JSONDecoder()
                let _ = try decoder.decode(Int.self, from: Data())
            } catch {
                confirmation()
                let manager = AlertManager("Read File Failed", error: error)
                
                #expect(manager.titleResource.key == "Read File Failed")
                #expect(manager.message == "The data couldn’t be read because it isn’t in the correct format.")
            }
        }
    }
    
    @Test func posxError() async throws {
        do {
            throw POSIXError(.ENOENT)
        } catch {
            let manager = AlertManager("Operation Failed", error: error)
            
            #expect(manager.titleResource.key == "Operation Failed")
            #expect(manager.message == "No such file or directory")
        }
    }
    
    @Test func cancelationError() async throws {
        do {
            throw CancellationError()
        } catch {
            let manager = AlertManager("Operation Failed", error: error)
            
            self._dump(error)
            
            #expect(manager.titleResource.key == "Operation Failed")
            #expect(manager.message == "Swift.CancellationError error 1.") // This is the only info we have.
        }
    }
    
    
    private func _dump(_ error: Error) {
        let nsError = error as NSError
        dump(nsError)
        print(nsError.localizedDescription)
        print(nsError.localizedFailureReason as Any)
        print(nsError.localizedRecoverySuggestion as Any)
    }
    
}
