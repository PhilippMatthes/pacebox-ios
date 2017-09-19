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
    
    @IBOutlet weak var lowSpeedField: UITextField!
    @IBOutlet weak var highSpeedField: UITextField!
    @IBOutlet weak var speedSelectionBackground: UIView!
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
    @IBOutlet weak var timeBackground: UIView!
    @IBOutlet weak var timeReplacementLabel: UILabel!
    
    let manager = CLLocationManager()
    
    var speedLog = [(Double, Double)]()
    var heightLog = [(Double, Double)]()
    var accelerationLog = [(Double, Double)]()
    var dragLog = [(Double, Double)]()
    
    var locations = [CLLocation]()
    var currentLocation = CLLocation()
    
    var currentSpeed = 0 as Double
    var currentHeight = 0 as Double
    var convertedCurrentSpeed = 0 as Double
    var maxSpeed = 0 as Double
    var convertedMaxSpeed = 0 as Double
    var avgSpeed = 0 as Double
    var convertedAvgSpeed = 0 as Double
    var currentHorizontalAccuracy = 5 as Double
    var currentGForce = 1 as Double
    
    var lowSpeed = 100 as Double
    var highSpeed = 200 as Double
    
    var drawRange = 60
    
    var speedType = "km/h"
    var speedTypeCoefficient = 3.6 as Double
    
    weak var timer: Timer?
    var startTime: Double = 0
    var currentTime: Double = 0
    
    var updateGraphs = Bool()
    
    var dragTime = Double()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLocationManager()
        setUpInterfaceDesign()
        setUpBackground(frame: self.view.bounds)
        setUpDoneButton()
        setUpChartView()
        setUpScrollView()
        startTimer()
        setUpMotionManager()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateGraphs = false
        timer?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateGraphs = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpMotionManager() {
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data,error) in
            let accurateCurrentGForce = sqrt (pow((data?.acceleration.x)!,2) + pow((data?.acceleration.y)!,2) + pow((data?
                .acceleration.z)!,2))
            self.currentGForce = Double(round(100 * accurateCurrentGForce)/100)
        }
    }
    
    func setUpScrollView() {
        scrollView.delegate = self
        scrollView.delaysContentTouches = true
        //        scrollView.isUserInteractionEnabled = true
        //        scrollView.isExclusiveTouch = true
        scrollView.canCancelContentTouches = true
        
        scrollView.addSubview(speedLogChartBackground)
        scrollView.addSubview(heightLogChartBackground)
        scrollView.addSubview(settingsBackground)
        scrollView.addSubview(accelerationLogChartBackground)
        scrollView.addSubview(speedSelectionBackground)
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
        self.speedSelectionBackground.layer.cornerRadius = 10.0
        self.timeBackground.layer.cornerRadius = 10.0
    }
    
    func setUpBackground(frame: CGRect) {
        gradientLayer.frame = frame
        let color1 = UIColor(red: 1.0, green: 0.666, blue: 0, alpha: 1.0).cgColor as CGColor
        let color2 = UIColor(red: 0.83, green: 0.10, blue: 0.10, alpha: 1.0).cgColor as CGColor
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0.0, 1.0]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setUpChartView() {
        speedLogChart.delegate = self
        heightLogChart.delegate = self
        accelerationLogChart.delegate = self
        
        speedLogChart.chartDescription?.text = nil
        speedLogChart.leftAxis.axisMinimum = 0
        speedLogChart.rightAxis.enabled = false
        
        heightLogChart.chartDescription?.text = nil
        heightLogChart.rightAxis.enabled = false
        
        accelerationLogChart.chartDescription?.text = nil
        accelerationLogChart.rightAxis.enabled = false
        
        let touchRecognizerSpeedLog = UITapGestureRecognizer(target: self, action:  #selector (self.speedLogPressed (_:)))
        let touchRecognizerHeightLog = UITapGestureRecognizer(target: self, action:  #selector (self.heightLogPressed (_:)))
        let touchRecognizerAccelerationLog = UITapGestureRecognizer(target: self, action:  #selector (self.accelerationLogPressed (_:)))
        
        speedLogChart.addGestureRecognizer(touchRecognizerSpeedLog)
        heightLogChart.addGestureRecognizer(touchRecognizerHeightLog)
        accelerationLogChart.addGestureRecognizer(touchRecognizerAccelerationLog)
    }
    
    func startTimer() {
        startTime = Date().timeIntervalSinceReferenceDate - currentTime
        timer = Timer.scheduledTimer(timeInterval: 0.05,
                                     target: self,
                                     selector: #selector(advanceTimer(timer:)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if updateGraphs {
            self.locations = locations
            currentLocation = self.locations[0]
            // Update current speed
            let speed = self.currentLocation.speed
            if speed >= 0.0 {
                currentSpeed = speed
            }
            // Update current height
            let height = self.currentLocation.altitude
            if height >= 0.0 {
                currentHeight = height
            }
            // Update height log
            heightLog.insert((currentTime, currentHeight), at: 0)
            if heightLog.count > drawRange {
                heightLog.remove(at: drawRange)
            }
            // Update speed log
            speedLog.insert((currentTime, currentSpeed), at: 0)
            while speedLog.count > drawRange {
                speedLog.remove(at: drawRange)
            }
            // Update acceleration log
            accelerationLog.insert((currentTime, currentGForce), at: 0)
            while speedLog.count > drawRange {
                speedLog.remove(at: drawRange)
            }
            // Convert current speed and save
            convertedCurrentSpeed = Double(round(100 * currentSpeed * speedTypeCoefficient)/100)
            let max = speedLog.max(by: {$0.1 < $1.1 })!.1
            if  max > maxSpeed {
                maxSpeed = max
            }
            convertedMaxSpeed = Double(round(100 * maxSpeed * speedTypeCoefficient)/100)
            currentHorizontalAccuracy = Double(round(100 * currentLocation.horizontalAccuracy)/100)
            refreshAllLabels()
            updateSpeedGraph()
            updateHeightGraph()
            updateAccelerationGraph()
        }
    }
    
    func setUpDoneButton() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(ViewController.doneButtonAction))
        done.tintColor = UIColor.orange
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.lowSpeedField.inputAccessoryView = doneToolbar
        self.highSpeedField.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        self.lowSpeedField.resignFirstResponder()
        self.highSpeedField.resignFirstResponder()
    }
    
    func advanceTimer(timer: Timer) {
        currentTime = Date().timeIntervalSinceReferenceDate - startTime
        if lowSpeed < highSpeed {
            checkForDragTime()
        }
    }
    
    func checkForDragTime() {
        var upperBoundFound = false
        var lowerBoundFound = false
        var currentIndex = 0
        var tempDragLog = [(Double, Double)]()
        
        while !upperBoundFound || !lowerBoundFound {
            
            if currentIndex == speedLog.count {
                return
            }
            
            if  speedLog[currentIndex].1 * speedTypeCoefficient >= highSpeed {
                if tempDragLog.count > 0 {
                    tempDragLog.remove(at: 0)
                }
                upperBoundFound = true
            }
            
            if (speedLog[currentIndex].1 * speedTypeCoefficient <= lowSpeed) && upperBoundFound {
                lowerBoundFound = true
            }
            
            if upperBoundFound {
                tempDragLog.insert(speedLog[currentIndex], at: 0)
            }
            
            currentIndex += 1
        }
        
        self.dragLog = tempDragLog
        
        let tuple3 = tempDragLog.popLast()!
        let tuple2 = tempDragLog.popLast()!
        let tuple1 = self.dragLog[1]
        let tuple0 = self.dragLog[0]
        
        let t3 = tuple3.0
        let t2 = tuple2.0
        let t1 = tuple1.0
        let t0 = tuple0.0
        
        let v3 = tuple3.1
        let v2 = tuple2.1
        let v1 = tuple1.1
        let v0 = tuple0.1
        
        let lowerTime = (v0*t1-v1*t0+(lowSpeed/speedTypeCoefficient)*t0-(lowSpeed/speedTypeCoefficient)*t1)/(v0-v1)
        let upperTime = (v2*t3-v3*t2+(highSpeed/speedTypeCoefficient)*t2-(highSpeed/speedTypeCoefficient)*t3)/(v2-v3)
        
        let correctedTime = upperTime - lowerTime
        if !correctedTime.isNaN {
            dragTime = Double(round(100 * correctedTime)/100)
            refreshAllLabels()
        }
    }
    
    func setUpLocationManager() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let screenSize = CGSize(width: size.width * 1.5, height: size.height * 1.5)
        let screenOrigin = CGPoint(x: 0, y: 0)
        let screenFrame = CGRect(origin: screenOrigin, size: screenSize)
        if UIDevice.current.orientation.isLandscape {
            setUpBackground(frame: screenFrame)
        } else if UIDevice.current.orientation.isPortrait {
            setUpBackground(frame: screenFrame)
        }
    }
    
    func refreshAllLabels() {
        DispatchQueue.main.async(execute:  {
            self.speedReplacementLabel.text = "\(self.convertedCurrentSpeed) "+self.speedType
            self.maxSpeedLabel.text = "\(self.convertedMaxSpeed) "+self.speedType
            self.accuracyLabel.text = "\(self.currentHorizontalAccuracy) m"
            self.accelerationLabel.text = "\(self.currentGForce) g"
            self.timeReplacementLabel.text = "\(self.dragTime) s"
        })
    }
    
    func updateSpeedGraph() {
        
        var lineChartEntriesSpeed = [ChartDataEntry]()
        var lineChartEntriesDrag = [ChartDataEntry]()
        
        for i in 0..<self.speedLog.count {
            let value = ChartDataEntry(x: speedLog[i].0, y: speedLog[i].1*speedTypeCoefficient)
            lineChartEntriesSpeed.insert(value, at: 0)
        }
        
        let dragLogLength = self.dragLog.count
        for i in 0..<dragLogLength {
            let value = ChartDataEntry(x: dragLog[dragLogLength-i-1].0, y: dragLog[dragLogLength-i-1].1*speedTypeCoefficient)
            lineChartEntriesDrag.insert(value, at: 0)
        }
        
        
        let speedLine = LineChartDataSet(values: lineChartEntriesSpeed, label: "Speed (in "+speedType+")")
        speedLine.drawCirclesEnabled = false
        speedLine.mode = LineChartDataSet.Mode.horizontalBezier
        speedLine.lineWidth = 1.0
        speedLine.drawFilledEnabled = true
        speedLine.colors = [NSUIColor.orange]
        
        let dragLine = LineChartDataSet(values: lineChartEntriesDrag, label: String(lowSpeed)+" to "+String(highSpeed)+" "+speedType)
        dragLine.drawCirclesEnabled = false
        dragLine.mode = LineChartDataSet.Mode.horizontalBezier
        dragLine.lineWidth = 1.0
        dragLine.drawFilledEnabled = true
        dragLine.colors = [NSUIColor.black]
        
        let data = LineChartData()
        
        data.addDataSet(speedLine)
        data.addDataSet(dragLine)
        
        data.setDrawValues(false)
        
        speedLogChart.data = data
        self.speedLogChart.notifyDataSetChanged()
        
    }
    
    func updateHeightGraph() {
        
        var lineChartEntriesHeight = [ChartDataEntry]()
        
        for i in 0..<self.heightLog.count {
            let value = ChartDataEntry(x: heightLog[i].0, y: self.heightLog[i].1)
            lineChartEntriesHeight.insert(value, at: 0)
        }
        
        let heightLine = LineChartDataSet(values: lineChartEntriesHeight, label: "Height in m")
        heightLine.drawCirclesEnabled = false
        heightLine.mode = LineChartDataSet.Mode.horizontalBezier
        heightLine.lineWidth = 1.0
        heightLine.drawFilledEnabled = true
        heightLine.colors = [NSUIColor.orange]
        
        let data = LineChartData()
        
        data.addDataSet(heightLine)
        
        data.setDrawValues(false)
        
        heightLogChart.data = data
        self.heightLogChart.notifyDataSetChanged()
        
        
    }
    
    func updateAccelerationGraph() {
        
        var lineChartEntriesHeight = [ChartDataEntry]()
        
        for i in 0..<self.accelerationLog.count {
            let value = ChartDataEntry(x: accelerationLog[i].0, y: self.accelerationLog[i].1)
            lineChartEntriesHeight.insert(value, at: 0)
        }
        
        let accelerationLine = LineChartDataSet(values: lineChartEntriesHeight, label: "Acceleration in g")
        accelerationLine.drawCirclesEnabled = false
        accelerationLine.mode = LineChartDataSet.Mode.horizontalBezier
        accelerationLine.lineWidth = 1.0
        accelerationLine.drawFilledEnabled = true
        accelerationLine.colors = [NSUIColor.orange]
        
        let data = LineChartData()
        
        data.addDataSet(accelerationLine)
        
        data.setDrawValues(false)
        
        accelerationLogChart.data = data
        self.accelerationLogChart.notifyDataSetChanged()
        
        
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
    
    @IBAction func highSpeedField(_ sender: UITextField) {
        if let input = Double(sender.text!) {
            highSpeed = input
            highSpeedField.text = String(highSpeed)
        }
        else {
            highSpeedField.text = String(highSpeed)
        }
    }
    
    @IBAction func lowSpeedField(_ sender: UITextField) {
        if let input = Double(sender.text!) {
            lowSpeed = input
            lowSpeedField.text = String(lowSpeed)
        }
        else {
            lowSpeedField.text = String(lowSpeed)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSpeedLogDetail" {
            let vc = segue.destination as! SpeedLogDetailController
            vc.previousViewController = self
            
            vc.speedLog = self.speedLog
            vc.speedType = self.speedType
            vc.speedTypeCoefficient = self.speedTypeCoefficient
            vc.drawRange = self.drawRange
        }
        if segue.identifier == "showHeightLogDetail" {
            let vc = segue.destination as! HeightLogDetailController
            vc.previousViewController = self
            vc.heightLog = self.heightLog
            vc.drawRange = self.drawRange
        }
        if segue.identifier == "showAccelerationLogDetail" {
            let vc = segue.destination as! AccelerationLogDetailController
            vc.previousViewController = self
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

