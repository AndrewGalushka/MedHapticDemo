//
//  HapticEngineWrapper.swift
//  Meditation Haptic Test
//
//  Created by Andrii Halushka on 08.06.2021.
//

import CoreHaptics

class BreathHapticEngine {
    private let engine: CHHapticEngine
    
    private var breathInPlayer: CHHapticPatternPlayer?
    private var breathOutPlayer: CHHapticPatternPlayer?
    private var breathDownStepPlayer: CHHapticPatternPlayer?
    
    init() throws {
        engine = try CHHapticEngine()
        engine.resetHandler = { [weak self] in
            self?.handleEngineReset()
        }
        
        engine.stoppedHandler = { [weak self] (stopReason) in
            self?.handleExternalEventEngineStop(stopReason)
        }
    }
    
    // MARK: - Public API
    
    func prepare() {
        do {
            try engine.start()
            self.breathInPlayer = try engine.makePlayer(with: try Configs.makeBreathInPattern())
            self.breathOutPlayer = try engine.makePlayer(with: try Configs.makeBreathOutPattern())
            self.breathDownStepPlayer = try Configs.makeBreathOutStepPattern().flatMap { try engine.makePlayer(with: $0) }
        } catch let error {
            print("Couldn't prepare the engine: \(error.localizedDescription)")
        }
    }
    
    func playBreathIn() {
        do {
            try breathInPlayer?.start(atTime: .zero)
        } catch let error {
            print("Couldn't play `BreathIn player`: \(error.localizedDescription)")
        }
    }
    
    func playBreathOut() {
        do {
            try breathOutPlayer?.start(atTime: .zero)
        } catch let error {
            print("Couldn't play `BreathOut player`: \(error.localizedDescription)")
        }
    }
    
    func playBreathDownStep() {
        do {
            try breathDownStepPlayer?.start(atTime: .zero)
        } catch let error {
            print("Couldn't play `BreathDownStep player`: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private API
    
    private func handleEngineReset() {
        engine.start { error in
            if let error = error {
                print("Failed to start the engine with \(error.localizedDescription)")
            }
        }
    }
    
    private func handleExternalEventEngineStop(_ stopReason: CHHapticEngine.StoppedReason) {
        print("Stop Handler: The engine stopped for reason: \(stopReason.rawValue)")
        switch stopReason {
        case .audioSessionInterrupt: print("Audio session interrupt")
        case .applicationSuspended: print("Application suspended")
        case .idleTimeout: print("Idle timeout")
        case .systemError: print("System error")
        case .notifyWhenFinished: print("Finished work")
        case .engineDestroyed: print("Engine Destroyed")
        case .gameControllerDisconnect: print("Game Controller disconnect")
        @unknown default:
            print("Unknown error")
        }
        
        prepare()
    }
}

// MARK: - Configs

extension BreathHapticEngine {
    private enum Configs {
        
        // MARK: - Breath In
        
        static func makeBreathOutStepPattern() throws -> CHHapticPattern? {
            guard let ahapDict = try loadDictionary(fileName: "Heartbeats.ahap") else {
                return nil
            }
            
            return try CHHapticPattern(dictionary: ahapDict)
        }
        
        static func makeBreathInPattern() throws -> CHHapticPattern {
            let timingOffset = 0.25
            
            let step1 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                ],
                relativeTime: 0
            )
            
            let step2 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                ],
                relativeTime: timingOffset
            )
            
            let step3 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                ],
                relativeTime: timingOffset * 2
            )
            
            let step4 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                ],
                relativeTime: timingOffset * 3
            )
            
            return try CHHapticPattern(events: [step1, step2, step3, step4],
                                       parameterCurves: [])
        }
        
        // MARK: - Breath Out
        
        static func makeBreathOutPattern() throws -> CHHapticPattern {
            let timingOffset = 0.5
            
            var currentTimeOffset: TimeInterval = 0
            var currentIteration = 0
            
            func nextRelativeTime() -> TimeInterval {
                let nextTimeOffset = currentTimeOffset + timingOffset
                
                currentTimeOffset = nextTimeOffset
                currentIteration = currentIteration + 1
                
                return nextTimeOffset
            }
            
            let step1 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: nextRelativeTime()
            )
            
            
            let step2 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: nextRelativeTime()
            )
            
            let step3 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: nextRelativeTime()
            )
            
            let step4 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: nextRelativeTime()
            )
            
//            let curve = CHHapticParameterCurve(parameterID: .hapticIntensityControl,
//                                               controlPoints: [CHHapticParameterCurve.ControlPoint(relativeTime: 0.5, value: 1)],
//                                               relativeTime: currentTimeOffset * 1.0)
            
            return try CHHapticPattern(events: [step1, step2, step3, step4],
                                       parameterCurves: [])
        }
        
        private static func loadDictionary(fileName: String) throws -> [CHHapticPattern.Key : Any]? {
            let bundle = Bundle(for: BreathHapticEngine.self)
            
            guard let url = bundle.url(forResource: fileName, withExtension: "") else {
                return nil
            }
            
            return try JSONSerialization.jsonObject(with: try Data(contentsOf: url), options: []) as? [CHHapticPattern.Key: Any]
        }
    }
}
