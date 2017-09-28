//
//  Measurement.swift
//  DragTimer
//
//  Created by Philipp Matthes on 26.09.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import CoreLocation

class Measurement {
    var time = Double()
    var speedLog = [Double]()
    var heightLog = [Double]()
    var accelerationLog = [Double]()

    init(time: Double, speedLog: [Double], heightLog: [Double], accelerationLog: [Double]) {
        self.time = time
        self.speedLog = speedLog
        self.heightLog = heightLog
        self.accelerationLog = accelerationLog
    }
}
