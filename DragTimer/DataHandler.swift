//
//  DataHandler.swift
//  DragTimer
//
//  Created by Philipp Matthes on 27.09.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation

class DataHandler {
    
    init() {}
    
    func store(log: [(Double, Double)], identifier: String) {
        let encodedValues = log.map{return ["0":$0.0, "1":$0.1]}
        UserDefaults.standard.set(encodedValues, forKey: identifier)
    }
    
    func load(logName: String) -> [(Double, Double)] {
        guard let encodedArray = UserDefaults.standard.array(forKey: logName) else {return []}
        return encodedArray.map{$0 as? NSDictionary}.flatMap{
            guard let values = $0 else {return nil}
            if let xValue = values["0"] as? Double {
                if let yValue = values["1"] as? Double {
                    return (xValue, yValue)
                }
                else {
                    return nil
                }
            } else {
                return nil
            }
        }
    }
    
}
