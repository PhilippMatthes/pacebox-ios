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
    var identifier: String?
    var time: Double?
    var correctedTime: Double?
    var speedLog: [(Double, Double)]?
    var heightLog: [(Double, Double)]?
    var accelerationLog: [(Double, Double)]?
    var dragLog: [(Double, Double)]?
    var lowSpeed: Double?
    var highSpeed: Double?
    var speedTypeCoefficient: Double?
    var speedType: String?
    var weight: Double?
    var weightType: String?
    var weightTypeCoefficient: Double?
    var date: String?
    var drawRange: Int?
    
    init(identifier: String,
         time: Double,
         correctedTime: Double,
         speedLog: [(Double, Double)],
         heightLog: [(Double, Double)],
         accelerationLog: [(Double, Double)],
         dragLog: [(Double, Double)],
         lowSpeed: Double,
         highSpeed: Double,
         speedTypeCoefficient: Double,
         speedType: String,
         weight: Double,
         weightType: String,
         weightTypeCoefficient: Double,
         date: String,
         drawRange: Int) {
        self.identifier = identifier
        self.time = time
        self.correctedTime = correctedTime
        self.speedLog = speedLog
        self.heightLog = heightLog
        self.accelerationLog = accelerationLog
        self.dragLog = dragLog
        self.lowSpeed = lowSpeed
        self.highSpeed = highSpeed
        self.speedTypeCoefficient = speedTypeCoefficient
        self.speedType = speedType
        self.weight = weight
        self.weightType = weightType
        self.weightTypeCoefficient = weightTypeCoefficient
        self.date = date
        self.drawRange = drawRange
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        guard
            let identifier = aDecoder.decodeObject(forKey: "identifier") as? String,
            let time = aDecoder.decodeObject(forKey: "time") as? Double,
            let correctedTime = aDecoder.decodeObject(forKey: "correctedTime") as? Double,
            let lowSpeed = aDecoder.decodeObject(forKey: "lowSpeed") as? Double,
            let highSpeed = aDecoder.decodeObject(forKey: "highSpeed") as? Double,
            let speedTypeCoefficient = aDecoder.decodeObject(forKey: "speedTypeCoefficient") as? Double,
            let speedType = aDecoder.decodeObject(forKey: "speedType") as? String,
            let date = aDecoder.decodeObject(forKey: "date") as? String,
            let weight = aDecoder.decodeObject(forKey: "weight") as? Double,
            let weightType = aDecoder.decodeObject(forKey: "weightType") as? String,
            let weightTypeCoefficient = aDecoder.decodeObject(forKey: "weightTypeCoefficient") as? Double,
            let drawRange = aDecoder.decodeObject(forKey: "drawRange") as? Int
        else {
            return nil
        }
        let data = DataHandler()
        let speedLog = data.load(logName: "speedLog"+identifier)
        let heightLog = data.load(logName: "heightLog"+identifier)
        let accelerationLog = data.load(logName: "accelerationLog"+identifier)
        let dragLog = data.load(logName: "dragLog"+identifier)
        self.init(identifier: identifier,
                  time: time,
                  correctedTime: correctedTime,
                  speedLog: speedLog,
                  heightLog: heightLog,
                  accelerationLog: accelerationLog,
                  dragLog: dragLog,
                  lowSpeed: lowSpeed,
                  highSpeed: highSpeed,
                  speedTypeCoefficient: speedTypeCoefficient,
                  speedType: speedType,
                  weight: weight,
                  weightType: weightType,
                  weightTypeCoefficient: weightTypeCoefficient,
                  date: date,
                  drawRange: drawRange)
    }
    
    func encode(with aCoder: NSCoder) {
        let data = DataHandler()
        aCoder.encode(identifier, forKey: "identifier")
        aCoder.encode(time, forKey: "time")
        aCoder.encode(correctedTime, forKey: "correctedTime")
        data.store(log: speedLog!, identifier: "speedLog"+identifier!)
        data.store(log: heightLog!, identifier: "heightLog"+identifier!)
        data.store(log: accelerationLog!, identifier: "accelerationLog"+identifier!)
        data.store(log: dragLog!, identifier: "dragLog"+identifier!)
        aCoder.encode(lowSpeed, forKey: "lowSpeed")
        aCoder.encode(highSpeed, forKey: "highSpeed")
        aCoder.encode(speedTypeCoefficient, forKey: "speedTypeCoefficient")
        aCoder.encode(speedType, forKey: "speedType")
        aCoder.encode(weight, forKey: "weight")
        aCoder.encode(weightType, forKey: "weightType")
        aCoder.encode(weightTypeCoefficient, forKey: "weightTypeCoefficient")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(drawRange, forKey: "drawRange")
    }
}
