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
    
    // Speed label on main view for speed displaying
    @IBOutlet weak var speedReplacementLabel: UILabel!
    @IBOutlet var background: UIView!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    
    
    let manager = CLLocationManager()
    var speedLog = [Double]()

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        self.speedLog.append(location.speed)
        let convertedSpeed = Double(round(1000 * location.speed * 3.6)/1000)
        
        DispatchQueue.main.async {
            self.speedReplacementLabel.text = "\(convertedSpeed) km/h"
        }
        
        let maxSpeed = self.speedLog.max()!
        let convertedMaxSpeed = Double(round(1000 * maxSpeed * 3.6)/1000)
        self.maxSpeedLabel.text = "Max Speed: \(convertedMaxSpeed) km/h"
        
        
        //background.backgroundColor = UIColor(red: (255.0/255.0), green: (255.0/255.0), blue: (255.0/255.0), alpha: CGFloat(location.speed/maxSpeed))
        
        
 
        }

    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

