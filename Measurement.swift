//
//  Measurement.swift
//  DragTimer
//
//  Created by Philipp Matthes on 26.09.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import CoreLocation

class Measurement: NSObject, NSCoding  {
    var time: Double?
    var speedLog: [(Double, Double)]?
    var heightLog: [(Double, Double)]?
    var accelerationLog: [(Double, Double)]?
    var lowSpeed: Double?
    var highSpeed: Double?
    var speedTypeCoefficient: Double?
    var speedType: String?
    var date: String?
    
    init(time: Double,
         speedLog: [(Double, Double)],
         heightLog: [(Double, Double)],
         accelerationLog: [(Double, Double)],
         lowSpeed: Double,
         highSpeed: Double,
         speedTypeCoefficient: Double,
         speedType: String,
         date: String) {
        self.time = time
        self.speedLog = speedLog
        self.heightLog = heightLog
        self.accelerationLog = accelerationLog
        self.lowSpeed = lowSpeed
        self.highSpeed = highSpeed
        self.speedTypeCoefficient = speedTypeCoefficient
        self.speedType = speedType
        self.date = date
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        let data = DataHandler()
        let speedLog = data.load(logName: "speedLog")
        let heightLog = data.load(logName: "heightLog")
        let accelerationLog = data.load(logName: "accelerationLog")
        guard
            let time = aDecoder.decodeObject(forKey: "time") as? Double,
            let lowSpeed = aDecoder.decodeObject(forKey: "lowSpeed") as? Double,
            let highSpeed = aDecoder.decodeObject(forKey: "highSpeed") as? Double,
            let speedTypeCoefficient = aDecoder.decodeObject(forKey: "speedTypeCoefficient") as? Double,
            let speedType = aDecoder.decodeObject(forKey: "speedType") as? String,
            let date = aDecoder.decodeObject(forKey: "date") as? String
        else {
            return nil
        }
        self.init(time: time,
                  speedLog: speedLog,
                  heightLog: heightLog,
                  accelerationLog: accelerationLog,
                  lowSpeed: lowSpeed,
                  highSpeed: highSpeed,
                  speedTypeCoefficient: speedTypeCoefficient,
                  speedType: speedType,
                  date: date)
    }
    
    func encode(with aCoder: NSCoder) {
        let data = DataHandler()
        aCoder.encode(time, forKey: "time")
        data.store(log: speedLog!, identifier: "speedLog")
        data.store(log: heightLog!, identifier: "heightLog")
        data.store(log: accelerationLog!, identifier: "accelerationLog")
        aCoder.encode(lowSpeed, forKey: "lowSpeed")
        aCoder.encode(highSpeed, forKey: "highSpeed")
        aCoder.encode(speedTypeCoefficient, forKey: "speedTypeCoefficient")
        aCoder.encode(speedType, forKey: "speedType")
        aCoder.encode(date, forKey: "date")
    }
}
