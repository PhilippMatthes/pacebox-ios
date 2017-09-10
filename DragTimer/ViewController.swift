//
//  ViewController.swift
//  DragTimer
//
//  Created by Philipp Matthes on 07.08.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let gradientLayer = CAGradientLayer()
    
    // Speed label on main view for speed displaying
    @IBOutlet weak var speedReplacementLabel: UILabel!
    @IBOutlet var background: UIView!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var speedTypeButton: UIButton!
    
    @IBOutlet weak var maxSpeedBackground: UIView!
    @IBOutlet weak var currentSpeedBackground: UIView!
    @IBOutlet weak var currentSpeedStackView: UIStackView!
    
    
    let manager = CLLocationManager()
    var speedLog = [Double]()
    var locations = [CLLocation]()
    
    var currentLocation = CLLocation()
    var currentSpeed = 0.0
    var convertedCurrentSpeed = 0.0
    var currentGhostTime = 0.0
    let refreshInterval = 0.1
    
    var maxSpeed = 0.0
    var convertedMaxSpeed = 0.0
    
    var speedType = "km/h"
    var speedTypeCoefficient = 3.6
    

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.locations = locations
        self.currentLocation = self.locations[0]
        
        let speed = self.currentLocation.speed
        if speed >= 0.0 {
            self.currentSpeed = speed
        }
        self.speedLog.insert(self.currentSpeed, at: 0)
        self.convertedCurrentSpeed = Double(round(1000 * self.currentSpeed * self.speedTypeCoefficient)/1000)
        
        
        self.maxSpeed = self.speedLog.max()!
        self.convertedMaxSpeed = Double(round(1000 * self.maxSpeed * self.speedTypeCoefficient)/1000)
        
        //let horizontalAccuracy: CLLocationAccuracy = self.currentLocation.horizontalAccuracy
        
        self.currentGhostTime = 0.0
        
        self.refreshAllLabels()
        
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        self.currentSpeedBackground.layer.cornerRadius = 10.0
        self.maxSpeedBackground.layer.cornerRadius = 10.0
        
        gradientLayer.frame = self.view.bounds
        let color1 = UIColor(red: 1.0, green: 0.666, blue: 0, alpha: 1.0).cgColor as CGColor
        let color2 = UIColor(red: 0.83, green: 0.10, blue: 0.10, alpha: 1.0).cgColor as CGColor
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0.0, 1.0]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func speedTypeButtonPressed(_ sender: UIButton){
        let alertController = UIAlertController(
            title: "Available Speed Types",
            message: "Select your corresponding speed type",
            preferredStyle: UIAlertControllerStyle.actionSheet
        )
        
        // User selects km/h
        let speedTypeKphAction = UIAlertAction (
            title: "Kilometers per hour (km/h)",
            style: UIAlertActionStyle.destructive
        ) {
            (action) -> Void in
            self.speedType = "km/h"
            self.speedTypeCoefficient = 3.6
            self.refreshAllLabels()
        }
        
        let speedTypeMphAction = UIAlertAction (
            title: "Miles per hour (mph)",
            style: UIAlertActionStyle.default
        ) {
            (action) -> Void in
            self.speedType = "mph"
            self.speedTypeCoefficient = 2.23694
            self.refreshAllLabels()
        }
        
        let cancelButtonAction = UIAlertAction (
            title: "Cancel",
            style: UIAlertActionStyle.cancel
        ) {
            (action) -> Void in
            print("User cancelled action.")
        }
        
        alertController.addAction(speedTypeKphAction)
        alertController.addAction(speedTypeMphAction)
        alertController.addAction(cancelButtonAction)
        
        let popOver = alertController.popoverPresentationController
        popOver?.sourceView = sender as UIView
        popOver?.sourceRect = (sender as UIView).bounds
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func refreshAllLabels() {
        DispatchQueue.main.async(execute:  {
            let text = "\(self.convertedCurrentSpeed)"
            self.speedReplacementLabel.text = text
            self.speedTypeButton.setTitle(self.speedType, for: .normal)
            self.maxSpeedLabel.text = "Max Speed: \(self.convertedMaxSpeed) "+self.speedType
        })
    }
    
//    func refreshCalculatedLabels() {
//        DispatchQueue.main.async(execute:  {
//            if self.currentGhostTime < 1 {
//                if self.speedLog.count > 1 {
//                    let delta = self.speedLog[0] - self.speedLog[1]
//                    self.currentSpeed += self.currentGhostTime * delta
//                    self.convertedCurrentSpeed = Double(round(1000 * self.currentSpeed * self.speedTypeCoefficient)/1000)
//                    self.currentGhostTime += self.refreshInterval
//                }
//                if self.convertedCurrentSpeed >= 0.0 {
//                    let text = "\(self.convertedCurrentSpeed)"
//                    self.speedReplacementLabel.text = text
//                    self.speedTypeButton.setTitle(self.speedType, for: .normal)
//                    self.maxSpeedLabel.text = "Max Speed: \(self.convertedMaxSpeed) "+self.speedType
//                }
//            }
//        })
//    }


}

