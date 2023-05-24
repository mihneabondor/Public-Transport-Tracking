//
//  MotionManager.swift
//  Public-Transport-Tracking
//
//  Created by Mihnea on 5/7/23.
//

import Foundation
import CoreMotion

class MotionManager : ObservableObject {
    private let motionManager = CMMotionManager()
    @Published var x = 0.0
    @Published var y = 0.0
    
    init() {
        motionManager.deviceMotionUpdateInterval = 1/15
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, err in
            guard let motion = data?.attitude else {return}
            self?.x = motion.roll
            self?.y = motion.pitch
        }
    }
}
