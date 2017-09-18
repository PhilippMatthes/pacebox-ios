//
//  ViewController.swift
//  DragTimer
//
//  Created by Philipp Matthes on 07.08.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import UIKit
import Charts
import CoreLocation
import CoreMotion

class ViewController: UIViewController, CLLocationManagerDelegate, ChartViewDelegate, UIScrollViewDelegate {
    
    let gradientLayer = CAGradientLayer()
    
    var motionManager = CMMotionManager()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var speedReplacementLabel: UILabel!
    @IBOutlet var background: UIView!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var accuracyLabel: UILabel!
    @IBOutlet weak var accuracyBackground: UIView!
    
    
    @IBOutlet weak var settingsBackground: UIView!
    @IBOutlet weak var maxSpeedBackground: UIView!
    @IBOutlet weak var currentSpeedBackground: UIView!
    
    @IBOutlet weak var accelerationLabel: UILabel!
    @IBOutlet weak var accelerationBackground: UIView!
    @IBOutlet weak var speedLogChart: LineChartView!
    @IBOutlet weak var speedLogChartBackground: UIView!
    @IBOutlet weak var heightLogChart: LineChartView!
    @IBOutlet weak var heightLogChartBackground: UIView!
    @IBOutlet weak var accelerationLogChart: LineChartView!
    @IBOutlet weak var accelerationLogChartBackground: UIView!
    
    let manager = CLLocationManager()
    var speedLog = [(Double, Double)]()
    var heightLog = [(Double, Double)]()
    var accelerationLog = [(Double, Double)]()
    var locations = [CLLocation]()
    
    var currentLocation = CLLocation()
    var currentSpeed = 0.0
    var currentHeight = 0.0
    var convertedCurrentSpeed = 0.0
    var maxSpeed = 0.0
    var convertedMaxSpeed = 0.0
    var avgSpeed = 0.0
    var convertedAvgSpeed = 0.0
    var currentHorizontalAccuracy = 5.0
    var currentGForce = 1.0
    
    var drawRange = 60
    
    var speedType = "km/h"
    var speedTypeCoefficient = 3.6
    
    weak var timer: Timer?
    var startTime: Double = 0
    var currentTime: Double = 0
    
    var updateGraphs = Bool()
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if updateGraphs {
        
            self.locations = locations
            self.currentLocation = self.locations[0]
        
            // Update current speed
            let speed = self.currentLocation.speed
            if speed >= 0.0 {
                self.currentSpeed = speed
            }
        
            // Update current height
            let height = self.currentLocation.altitude
            if height >= 0.0 {
                self.currentHeight = height
            }
        
            // Update height log
            heightLog.insert((currentTime, currentHeight), at: 0)
            if heightLog.count > drawRange {
                self.heightLog.remove(at: self.drawRange)
            }
        
            // Update speed log
            speedLog.insert((currentTime, self.currentSpeed), at: 0)
            while speedLog.count > drawRange {
                speedLog.remove(at: drawRange)
            }
            
            // Update acceleration log
            accelerationLog.insert((currentTime, self.currentGForce), at: 0)
            while speedLog.count > drawRange {
                speedLog.remove(at: drawRange)
            }
        
            // Convert current speed and save
            self.convertedCurrentSpeed = Double(round(100 * self.currentSpeed * self.speedTypeCoefficient)/100)
        
            let max = self.speedLog.max(by: {$0.1 < $1.1 })!.1
            if  max > self.maxSpeed {
                self.maxSpeed = max
            }
            self.convertedMaxSpeed = Double(round(100 * self.maxSpeed * self.speedTypeCoefficient)/100)
        
        
            self.currentHorizontalAccuracy = Double(round(100 * self.currentLocation.horizontalAccuracy)/100)
        
            self.refreshAllLabels()
            self.updateSpeedGraph()
            self.updateHeightGraph()
            self.updateAccelerationGraph()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        self.setUpInterfaceDesign()
        
        self.speedLogChart.delegate = self
        self.heightLogChart.delegate = self
        
        let touchRecognizerSpeedLog = UITapGestureRecognizer(target: self, action:  #selector (self.speedLogPressed (_:)))
        let touchRecognizerHeightLog = UITapGestureRecognizer(target: self, action:  #selector (self.heightLogPressed (_:)))
        let touchRecognizerAccelerationLog = UITapGestureRecognizer(target: self, action:  #selector (self.accelerationLogPressed (_:)))
        
        speedLogChart.addGestureRecognizer(touchRecognizerSpeedLog)
        heightLogChart.addGestureRecognizer(touchRecognizerHeightLog)
        accelerationLogChart.addGestureRecognizer(touchRecognizerAccelerationLog)
        
        scrollView.delegate = self
        scrollView.delaysContentTouches = true
        scrollView.isUserInteractionEnabled = true
        scrollView.isExclusiveTouch = true
        scrollView.canCancelContentTouches = true
        
        scrollView.addSubview(speedLogChartBackground)
        scrollView.addSubview(heightLogChartBackground)
        scrollView.addSubview(settingsBackground)
        scrollView.addSubview(accelerationLogChartBackground)
        
        startTimer()
        
        motionManager.accelerometerUpdateInterval = 0.2
        
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data,error) in
            let accurateCurrentGForce = sqrt (pow((data?.acceleration.x)!,2) + pow((data?.acceleration.y)!,2) + pow((data?
                .acceleration.z)!,2))
            self.currentGForce = Double(round(100 * accurateCurrentGForce)/100)
        }
        
    }
    
    func startTimer() {
        startTime = Date().timeIntervalSinceReferenceDate - currentTime
        timer = Timer.scheduledTimer(timeInterval: 0.05,
                                     target: self,
                                     selector: #selector(advanceTimer(timer:)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateGraphs = false
        timer?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateGraphs = true
    }
    
    func advanceTimer(timer: Timer) {
        
        //Total time since timer started, in seconds
        currentTime = Date().timeIntervalSinceReferenceDate - startTime
    }
    
    func setUpInterfaceDesign() {
        self.currentSpeedBackground.layer.cornerRadius = 10.0
        self.maxSpeedBackground.layer.cornerRadius = 10.0
        self.settingsBackground.layer.cornerRadius = 10.0
        self.accuracyBackground.layer.cornerRadius = 10.0
        self.speedLogChartBackground.layer.cornerRadius = 10.0
        self.heightLogChartBackground.layer.cornerRadius = 10.0
        self.accelerationBackground.layer.cornerRadius = 10.0
        self.accelerationLogChartBackground.layer.cornerRadius = 10.0
        
        setUpBackground(frame: self.view.bounds)
    }
    
    func setUpBackground(frame: CGRect) {
        gradientLayer.frame = frame
        let color1 = UIColor(red: 1.0, green: 0.666, blue: 0, alpha: 1.0).cgColor as CGColor
        let color2 = UIColor(red: 0.83, green: 0.10, blue: 0.10, alpha: 1.0).cgColor as CGColor
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0.0, 1.0]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let screenSize = CGSize(width: size.width * 1.5, height: size.height * 1.5)
        let screenOrigin = CGPoint(x: 0, y: 0)
        let screenFrame = CGRect(origin: screenOrigin, size: screenSize)
        if UIDevice.current.orientation.isLandscape {
            self.setUpBackground(frame: screenFrame)
        } else if UIDevice.current.orientation.isPortrait {
            self.setUpBackground(frame: screenFrame)
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func refreshAllLabels() {
        DispatchQueue.main.async(execute:  {
            self.speedReplacementLabel.text = "\(self.convertedCurrentSpeed) "+self.speedType
            self.maxSpeedLabel.text = "\(self.convertedMaxSpeed) "+self.speedType
            self.accuracyLabel.text = "\(self.currentHorizontalAccuracy) m"
            self.accelerationLabel.text = "\(self.currentGForce) g"
        })
    }
    
    func updateSpeedGraph() {
        
        var lineChartEntriesSpeed = [ChartDataEntry]()
        
        for i in 0..<self.speedLog.count {
            let value = ChartDataEntry(x: speedLog[i].0, y: self.speedLog[i].1*self.speedTypeCoefficient)
            lineChartEntriesSpeed.insert(value, at: 0)
        }


        let speedLine = LineChartDataSet(values: lineChartEntriesSpeed, label: "Speed (in "+self.speedType+")")
        speedLine.drawCirclesEnabled = false
        speedLine.drawCubicEnabled = true
        speedLine.lineWidth = 2.0
        speedLine.drawFilledEnabled = true
        speedLine.colors = [NSUIColor.black]

        let data = LineChartData()
        
        data.addDataSet(speedLine)
        
        data.setDrawValues(false)

        self.speedLogChart.data = data
        self.speedLogChart.chartDescription?.text = nil
        self.speedLogChart.notifyDataSetChanged()
        
        self.speedLogChart.setVisibleXRange(minXRange: 0, maxXRange: Double(self.drawRange))
        self.speedLogChart.leftAxis.axisMinimum = 0
        self.speedLogChart.rightAxis.enabled = false
    }
    
    func updateHeightGraph() {
        
        var lineChartEntriesHeight = [ChartDataEntry]()
        
        for i in 0..<self.heightLog.count {
            let value = ChartDataEntry(x: heightLog[i].0, y: self.heightLog[i].1)
            lineChartEntriesHeight.insert(value, at: 0)
        }
        
        let heightLine = LineChartDataSet(values: lineChartEntriesHeight, label: "Height in m")
        heightLine.drawCirclesEnabled = false
        heightLine.drawCubicEnabled = true
        heightLine.lineWidth = 2.0
        heightLine.drawFilledEnabled = true
        heightLine.colors = [NSUIColor.orange]
        
        let data = LineChartData()
        
        data.addDataSet(heightLine)
        
        data.setDrawValues(false)
        
        self.heightLogChart.data = data
        self.heightLogChart.chartDescription?.text = nil
        self.heightLogChart.notifyDataSetChanged()
        
        self.heightLogChart.setVisibleXRange(minXRange: 0, maxXRange: Double(self.drawRange))
        self.heightLogChart.leftAxis.axisMinimum = 0
        self.heightLogChart.rightAxis.enabled = false
        
    }
    
    func updateAccelerationGraph() {
        
        var lineChartEntriesSpeed = [ChartDataEntry]()
        
        for i in 0..<self.accelerationLog.count {
            let value = ChartDataEntry(x: accelerationLog[i].0, y: self.accelerationLog[i].1)
            lineChartEntriesSpeed.insert(value, at: 0)
        }
        
        
        let accelerationLine = LineChartDataSet(values: lineChartEntriesSpeed, label: "Acceleration in g")
        accelerationLine.drawCirclesEnabled = false
        accelerationLine.drawCubicEnabled = true
        accelerationLine.lineWidth = 2.0
        accelerationLine.drawFilledEnabled = true
        accelerationLine.colors = [NSUIColor.darkGray]
        
        let data = LineChartData()
        
        data.addDataSet(accelerationLine)
        
        data.setDrawValues(false)
        
        self.accelerationLogChart.data = data
        self.accelerationLogChart.chartDescription?.text = nil
        self.accelerationLogChart.notifyDataSetChanged()
        
        self.accelerationLogChart.setVisibleXRange(minXRange: 0, maxXRange: Double(self.drawRange))
        self.accelerationLogChart.leftAxis.axisMinimum = 0
        self.accelerationLogChart.rightAxis.enabled = false
    }
    
    func speedLogPressed(_ sender:UITapGestureRecognizer) {
        performSegue(withIdentifier: "showSpeedLogDetail", sender: self)
    }
    
    func heightLogPressed(_ sender:UITapGestureRecognizer) {
        performSegue(withIdentifier: "showHeightLogDetail", sender: self)
    }
    
    func accelerationLogPressed(_ sender:UITapGestureRecognizer) {
        performSegue(withIdentifier: "showAccelerationLogDetail", sender: self)
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showSettings", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSpeedLogDetail" {
            let vc = segue.destination as! SpeedLogDetailController
            vc.speedLog = self.speedLog
            vc.speedType = self.speedType
            vc.speedTypeCoefficient = self.speedTypeCoefficient
            vc.drawRange = self.drawRange
        }
        if segue.identifier == "showHeightLogDetail" {
            let vc = segue.destination as! HeightLogDetailController
            vc.heightLog = self.heightLog
            vc.drawRange = self.drawRange
        }
        if segue.identifier == "showAccelerationLogDetail" {
            let vc = segue.destination as! AccelerationLogDetailController
            vc.accelerationLog = self.accelerationLog
            vc.drawRange = self.drawRange
        }
        if segue.identifier == "showSettings" {
            let vc = segue.destination as! SettingsController
            vc.previousViewController = self
            vc.drawRange = self.drawRange
            vc.speedTypeCoefficient = self.speedTypeCoefficient
            vc.speedType = self.speedType
        }
    }


}

