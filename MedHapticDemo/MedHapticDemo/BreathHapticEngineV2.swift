//
//  BreathHapticEngineV2.swift
//  MedHapticDemo
//
//  Created by Andrii Halushka on 17.08.2021.
//

import CoreHaptics

class BreathHapticEngineV2 {
    private let engine: CHHapticEngine
    private let logger: (String) -> Void
    
    private var breathInStartPlayer: CHHapticAdvancedPatternPlayer?
    private var breathOutStartPlayer: CHHapticAdvancedPatternPlayer?
    
    private var breathInStepPlayer: CHHapticPatternPlayer?
    private var breathOutStepPlayer: CHHapticPatternPlayer?
    
    private let hapticPatterns = HapticPatterns()
    
    fileprivate class HapticPatterns {
        var breathInStart: CHHapticPattern?
        var breathOutStart: CHHapticPattern?
        var breathInStep: CHHapticPattern?
        var breathOutStep: CHHapticPattern?
    }
    
    init(logger: @escaping (String) -> Void = { print($0) }) throws {
        self.logger = logger
        engine = try CHHapticEngine()
        
        engine.resetHandler = { [weak self] in
            logger("Haptic Engine reset --> Restarting!")
            self?.restart()
        }
        
        engine.stoppedHandler = { [weak self] (stopReason) in
            self?.handleExternalEventEngineStop(stopReason)
        }
    }
    
    // MARK: - Public API
    
    func prepare() throws {
        do {
            try initHapticPatters()
            try start()
        } catch let error {
            logger("Couldn't prepare the engine: \(error.localizedDescription)")
        }
    }
    
    func playBreathInStart() {
        guard let breathInStartPlayer = breathInStartPlayer else { return }
        
        do {
            try breathInStartPlayer.start(atTime: .zero)
        } catch let error {
            logger("Couldn't play `BreathIn player`: \(error.localizedDescription)")
        }
    }
    
    func playBreathOutStart() {
        guard let breathOutStartPlayer = breathOutStartPlayer else { return }
        
        do {
            try breathOutStartPlayer.start(atTime: .zero)
        } catch let error {
            logger("Couldn't play `BreathOut player`: \(error.localizedDescription)")
        }
    }
    
    func playBreathDownStep() {
        do {
            try breathOutStepPlayer?.start(atTime: .zero)
        } catch let error {
            logger("Couldn't play `BreathDownStep player`: \(error.localizedDescription)")
        }
    }
    
    func playBreathUpStep() {
        do {
            try breathInStepPlayer?.start(atTime: .zero)
        } catch let error {
            logger("Couldn't play `BreathDownStep player`: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private API
    
    private func initHapticPatters() throws {
        hapticPatterns.breathInStart = try PatternsFactory.makeBreathInStart()
        hapticPatterns.breathOutStart = try PatternsFactory.makeBreathOutStart()
        
        hapticPatterns.breathInStep = try PatternsFactory.makeBreathInStep()
        hapticPatterns.breathOutStep = try PatternsFactory.makeBreathOutStep()
    }
    
    private func start() throws {
        try engine.start()
        
        breathInStartPlayer = try engine.makeAdvancedPlayer(with: hapticPatterns.breathInStart!)
        breathOutStartPlayer = try engine.makeAdvancedPlayer(with: hapticPatterns.breathOutStart!)
        
        breathInStepPlayer = try engine.makePlayer(with: hapticPatterns.breathInStep!)
        breathOutStepPlayer = try engine.makePlayer(with: hapticPatterns.breathOutStep!)
    }
    
    private func restart() {
        do {
            try start()
        } catch let error {
            logger("Failed to restart haptic engine - \(error)")
        }
    }
    
    private func handleExternalEventEngineStop(_ stopReason: CHHapticEngine.StoppedReason) {
        print("Stop Handler: The engine stopped for reason: \(stopReason.rawValue)")
        switch stopReason {
        case .audioSessionInterrupt: logger("Audio session interrupt")
        case .applicationSuspended: logger("Application suspended")
        case .idleTimeout: logger("Idle timeout")
        case .systemError: logger("System error")
        case .notifyWhenFinished: logger("Finished work")
        case .engineDestroyed: logger("Engine Destroyed")
        case .gameControllerDisconnect: logger("Game Controller disconnect")
        @unknown default:
            logger("Unknown error")
        }
        
        restart()
    }
}

// MARK: - Configs

extension BreathHapticEngineV2 {
    private enum PatternsFactory {
        
        static func makeBreathOutStart() throws -> CHHapticPattern? {
            return try loadPattern(fileName: "ExhaleStart")
        }
        
        static func makeBreathOutStep() throws -> CHHapticPattern? {
            return try loadPattern(fileName: "BreathStep")
        }
        
        static func makeBreathInStart() throws -> CHHapticPattern? {
            return try loadPattern(fileName: "InhaleStart")
        }
        
        static func makeBreathInStep() throws -> CHHapticPattern? {
            return try loadPattern(fileName: "BreathStep")
        }
        
        private static func loadPattern(fileName: String) throws -> CHHapticPattern? {
            guard let dict = try loadDictionaryFromFile(fileName) else {
                return nil
            }
            
            return try CHHapticPattern(dictionary: dict)
        }
        private static func loadDictionaryFromFile(_ fileName: String) throws -> [CHHapticPattern.Key : Any]? {
            let bundle = Bundle(for: BreathHapticEngine.self)
            
            guard let url = bundle.url(forResource: fileName, withExtension: "ahap") else {
                return nil
            }
            
            return try JSONSerialization.jsonObject(with: try Data(contentsOf: url), options: []) as? [CHHapticPattern.Key: Any]
        }
    }
}
