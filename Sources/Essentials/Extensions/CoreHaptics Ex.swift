//
//  The Stratum Module - Extended Functionalities
//  The Stratum Module
//
//  Created by Vaida on 6/18/23.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

#if canImport(CoreHaptics)
import CoreHaptics
import OSLog


@available(macOS 11, iOS 14, watchOS 7, tvOS 14, *)
public extension CHHapticEngine {
    
    /// Creates a lazily global haptic engine.
    ///
    /// An engine can be created on different threads, and played on different threads. However this global one should not.
    nonisolated(unsafe)
    static let global: CHHapticEngine? = {
        let logger = Logger(subsystem: "CHHapticEngine", category: "simple initializer")
        
        do {
            let engine = try CHHapticEngine()
            engine.playsHapticsOnly = true
            engine.stoppedHandler = { reason in
                switch reason {
                case .audioSessionInterrupt:    logger.error("Haptic Engine Stopped: audio session interrupt")
                case .applicationSuspended:     logger.error("Haptic Engine Stopped: application suspended")
                case .idleTimeout:              logger.error("Haptic Engine Stopped: idle timeout")
                case .systemError:              logger.error("Haptic Engine Stopped: system error")
                case .engineDestroyed:          logger.error("Haptic Engine Stopped: engine reset")
                case .gameControllerDisconnect: logger.error("Haptic Engine Stopped: game controller disconnected")
                case .notifyWhenFinished:       break
                @unknown default:               logger.error("Haptic Engine Stopped: unknown error")
                }
            }
            
            try engine.start()
            
            return engine
        } catch {
            logger.error("\(error, privacy: .public)")
            return nil
        }
    }()
    
    
    /// Plays a given pattern.
    ///
    /// - Parameters:
    ///   - pattern: The pattern to be played.
    @inlinable
    func play(pattern: CHHapticPattern) throws {
        do {
            let player = try self.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch let error as CHHapticError {
            guard error.code.rawValue == -4805 else { throw error }
            try self.start()
            let player = try self.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        }
    }
    
}


@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension CHHapticPattern {
    
    /// Creates a transient pattern, registers as a tap or impulse.
    ///
    /// The haptic would start immediately. Both values ranges from 0.0 (weak) to 1.0 (strong).
    ///
    /// ```swift
    /// // Initialize and start the engine. Note that do not initializing and starting the engine repeatedly.
    /// let engine = CHHapticEngine.global
    ///
    /// // Create the pattern.
    /// let pattern = try CHHapticPattern(intensity: intensity, sharpness: sharpness)
    ///
    /// // Make the player and play.
    /// try engine.play(pattern: pattern)
    /// ```
    ///
    /// Or, use the compact line:
    ///
    /// ```swift
    /// try? CHHapticEngine.global?.play(pattern: .default)
    /// ```
    ///
    /// - Parameters:
    ///   - intensity: The strength of a haptic event. It is the volume of a haptic, indicating how impactful it feels in the user’s hand.
    ///   - sharpness: The feel of a haptic event. Patterns with low sharpness have a round and organic feel, whereas patterns with high sharpness feel more crisp and precise.
    ///   - attack: The time at which a haptic pattern’s intensity begins increasing.
    ///   - decay: The time at which a haptic pattern’s intensity begins decreasing.
    ///   - release: The time at which to begin fading the haptic pattern.
    ///   - sustained: A Boolean value that indicates whether to sustain a haptic event for its specified duration. If true, the engine sustains the haptic pattern throughout its specified duration, increasing only during its attackTime, and decreasing only after its decayTime. If false, the haptic doesn’t stay at full strength between attack and decay, tailing off even before its decay has begun.
    ///   - duration: The duration of the haptic event, in seconds.
    ///   - continuous: The type of the haptic event: transient or continuous.
    @inlinable
    convenience init(intensity: Float = 1,
                     sharpness: Float = 1,
                     attack: Float = 0,
                     decay: Float = 0,
                     release: Float = 0,
                     duration: Double = 0,
                     sustained: Bool = false,
                     continuous: Bool = false) throws {
        try self.init(
            events: [
                CHHapticEvent(
                    eventType: continuous ? .hapticContinuous : .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness),
                        CHHapticEventParameter(parameterID: .attackTime,      value: attack),
                        CHHapticEventParameter(parameterID: .decayTime,       value: decay),
                        CHHapticEventParameter(parameterID: .releaseTime,     value: release),
                        CHHapticEventParameter(parameterID: .sustained,       value: sustained ? 1 : 0),
                    ],
                    relativeTime: 0,
                    duration: duration
                )
            ],
            parameters: []
        )
    }
    
    /// Creates a default pattern.
    @inlinable
    static var `default`: CHHapticPattern {
        get throws {
            try CHHapticPattern(intensity: 1, sharpness: 1)
        }
    }
    
}
#endif
