//
//  ContentView.swift
//  MedHapticDemo
//
//  Created by Andrii Halushka on 16.08.2021.
//

import SwiftUI
import Combine

//let hapticEngine: BreathHapticEngine = {
//    let engine = try! BreathHapticEngine()
//    engine.prepare()
//    return engine
//}()

let hapticEngineV2: BreathHapticEngineV2 = {
    let engine = try! BreathHapticEngineV2()
    try! engine.prepare()
    return engine
}()

func handleStateChange(oldValue: DataModel.State, newValue: DataModel.State) {
    guard oldValue != newValue else { return }
    
    switch (oldValue, newValue) {
    case (.prepare, .started(_, _, let isExhale)):
        isExhale ? hapticEngineV2.playBreathOutStart() : hapticEngineV2.playBreathInStart()
    case (.started(_, _, let isOldDown), .started(_, _, let isNewDown)):
        let isPhaseChange = isOldDown != isNewDown
        
        if isNewDown {
            isPhaseChange ? hapticEngineV2.playBreathOutStart() : hapticEngineV2.playBreathDownStep()
        } else {
            isPhaseChange ? hapticEngineV2.playBreathInStart() : hapticEngineV2.playBreathUpStep()
        }
    default:
        break
    }
}

class DataModel: ObservableObject {
    @Published var state = State.idle {
        willSet {
           handleStateChange(oldValue: state, newValue: newValue)
        }
    }
    
    private var timer: Cancellable?
    
    enum State: Equatable {
        case idle
        case prepare
        case started(label: String, size: CGFloat, isDecrease: Bool)
    }
    
    enum Phase {
        case breathIn
        case breathOut
    }
    
    var dateStated = Date()
    var size: CGFloat = 1.0
    var isDecrease = false

    func start() {
        timer?.cancel()
        
        dateStated = Date()
        size = 1.0
        isDecrease = false
        
        func stepSize() {
            
            size += isDecrease ? -0.1 : 0.1
            
            if size >= 1.0 {
                isDecrease = true
                size = 0.9
            } else if size <= 0 {
                isDecrease = false
                size = 0.1
            }
        }
        
        state = .prepare
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] date in
                guard let self = self else { return }
                stepSize()
                self.state = .started(label: "\(self.size)", size: self.size, isDecrease: self.isDecrease)
            })
    }
    
    func reset() {
        timer?.cancel()
        state = .idle
    }
}

struct ContentView: View {
    @StateObject var dataModel = DataModel()
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Circle()
                    .foregroundColor(.snowWhite)
                    .frame(width: 200, height: 200)
                    .shadow(radius: 7)
                    .scaleEffect(circleScale())
                    .animation(animationForState())
                
                Button(action: {
                    switch dataModel.state {
                    case .idle:
                        dataModel.start()
                    case .started, .prepare:
                        dataModel.reset()
                    }
                }, label: {
                    Text(buttonTitle())
                })
            }
        }
    }
    
    private func buttonTitle() -> String {
        switch dataModel.state {
        case .idle:
            return "Start"
        case .prepare, .started:
            return "Finish"
        }
    }
    
    private func animationForState() -> Animation {
        switch dataModel.state {
        case .idle:
            return .easeOut
        case .started:
            return .linear(duration: 1)
        case .prepare:
            return .easeOut
        }
    }
    
    private func circleScale() -> CGFloat {
        switch dataModel.state {
        case .idle:
            return 0.5
        case .started(_, size: let size, _):
            return size
        case .prepare:
            return 1.0
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
