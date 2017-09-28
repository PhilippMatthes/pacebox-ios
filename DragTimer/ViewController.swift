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
import BRYXBanner

class ViewController: UIViewController, CLLocationManagerDelegate, ChartViewDelegate, UIScrollViewDelegate {
    
    var banner = Banner()
    
    let gradientLayer = CAGradientLayer()
    
    var motionManager = CMMotionManager()
    
    @IBOutlet weak var speedTypeLabel: UILabel!
    @IBOutlet weak var speedometerView: UIView!
    @IBOutlet weak var lowSpeedField: UITextField!
    @IBOutlet weak var highSpeedField: UITextField!
    @IBOutlet weak var speedReplacementLabel: UILabel!
    @IBOutlet var background: UIView!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var accuracyLabel: UILabel!
    @IBOutlet weak var accuracyBackground: UIView!
    @IBOutlet weak var settingsBackground: UIView!
    @IBOutlet weak var accelerationLabel: UILabel!
    @IBOutlet weak var accelerationBackground: UIView!
    @IBOutlet weak var speedLogChart: LineChartView!
    @IBOutlet weak var timeBackground: UIView!
    @IBOutlet weak var timeReplacementLabel: UILabel!
    @IBOutlet weak var savedMeasurementsButtonBackground: UIView!
    @IBOutlet weak var saveButtonBackground: UIView!
    
    let manager = CLLocationManager()
    
    var speedo = Speedometer()
    
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
    
    var lowSpeed = Double()
    var highSpeed = Double()
    
    var drawRange = Int()
    
    var speedType = String()
    var speedTypeCoefficient = Double()
    
    weak var timer: Timer?
    weak var speedometerTimer: Timer?
    var startTime: Double = 0
    var currentTime: Double = 0
    
    var updateGraphs = Bool()
    
    var dragTime = Double()
    
    var notificationFired = false
    var connectionEstablishedNotificationFired = false
    var noConnectionNotificationFired = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
        loadSettings()
        setUpSpeedometer()
        setUpLocationManager()
        setUpInterfaceDesign()
        setUpBackground(frame: self.view.bounds)
        setUpDoneButton()
        setUpChartView()
        startTimer()
        startSpeedometer()
        setUpMotionManager()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateGraphs = false
        timer?.invalidate()
        speedometerTimer?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateGraphs = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadSettings() {
        lowSpeed = UserDefaults.standard.object(forKey: "lowSpeed") as? Double ?? 0.0
        highSpeed = UserDefaults.standard.object(forKey: "highSpeed") as? Double ?? 100.0
        speedType = UserDefaults.standard.object(forKey: "speedType") as? String ?? "km/h"
        speedTypeCoefficient = UserDefaults.standard.object(forKey: "speedTypeCoefficient") as? Double ?? 3.6
        drawRange = UserDefaults.standard.object(forKey: "speedTypeCoefficient") as? Int ?? 60
    }
    
    func setUpSpeedometer() {
        // Create a new CircleView
        speedo = Speedometer(frame: speedometerView.frame)
        
        speedometerView.addSubview(speedo)

    }
    
    func setUpMotionManager() {
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data,error) in
            let accurateCurrentGForce = sqrt (pow((data?.acceleration.x)!,2) + pow((data?.acceleration.y)!,2) + pow((data?
                .acceleration.z)!,2))
            self.currentGForce = Double(round(100 * accurateCurrentGForce)/100)
        }
    }
    
    
    func setUpInterfaceDesign() {
        self.maxSpeedLabel.textColor = UIColor.gray
        self.speedTypeLabel.textColor = UIColor.gray
        self.speedReplacementLabel.textColor = UIColor.white
        self.settingsBackground.layer.cornerRadius = Constants.cornerRadius
        self.accuracyBackground.layer.cornerRadius = Constants.cornerRadius
        self.accelerationBackground.layer.cornerRadius = Constants.cornerRadius
        self.timeBackground.layer.cornerRadius = Constants.cornerRadius
        self.savedMeasurementsButtonBackground.layer.cornerRadius = Constants.cornerRadius
        self.saveButtonBackground.layer.cornerRadius = Constants.cornerRadius
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setUpBackground(frame: CGRect) {
        gradientLayer.frame = frame
        gradientLayer.colors = [Constants.backgroundColor1.cgColor as CGColor, Constants.backgroundColor2.cgColor as CGColor]
        gradientLayer.locations = [0.0, 1.0]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setUpChartView() {
        speedLogChart.delegate = self
        speedLogChart.chartDescription?.text = nil
        speedLogChart.leftAxis.axisMinimum = 0
        speedLogChart.rightAxis.enabled = false
        speedLogChart.leftAxis.enabled = false
        speedLogChart.xAxis.enabled = false
        speedLogChart.drawBordersEnabled = false
        speedLogChart.legend.enabled = false
        speedLogChart.isUserInteractionEnabled = false
        
        let touchRecognizerSpeedLog = UITapGestureRecognizer(target: self, action:  #selector (self.speedLogPressed (_:)))
        
        speedLogChart.addGestureRecognizer(touchRecognizerSpeedLog)
    }
    
    func startTimer() {
        startTime = Date().timeIntervalSinceReferenceDate - currentTime
        timer = Timer.scheduledTimer(timeInterval: 0.05,
                                     target: self,
                                     selector: #selector(advanceTimer(timer:)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func startSpeedometer() {
        startTime = Date().timeIntervalSinceReferenceDate - currentTime
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(advanceSpeedometerTimer(timer:)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let speed = locations[0].speed
        if speed >= 0.0 {
            currentSpeed = speed
            updateGraphs = true
            fireConnectionNotification(title: "Connection established!",
                                       subtitle: "We have a nice and clean GPS connection. Your speed will now be tracked.",
                                       connection: true,
                                       backgroundColor: Constants.designColor1)
        }
        else {
            updateGraphs = false
            fireConnectionNotification(title: "No Connection!",
                                       subtitle: "Your sensor couldn't calculate your speed. We'll wait for a stable GPS connection.",
                                       connection: false,
                                       backgroundColor: Constants.designColor2)
        }
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
            while accelerationLog.count > drawRange {
                accelerationLog.remove(at: drawRange)
            }
            if var dragLogLastTime = dragLog.first?.0 {
                while dragLogLastTime < currentTime - Double(drawRange) && dragLog.count > 0 {
                    dragLogLastTime = dragLog.removeFirst().0
                }
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
        }
    }
    
    func setUpDoneButton() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(ViewController.doneButtonAction))
        done.tintColor = Constants.designColor1
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.lowSpeedField.inputAccessoryView = doneToolbar
        self.highSpeedField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        self.lowSpeedField.resignFirstResponder()
        self.highSpeedField.resignFirstResponder()
    }
    
    @objc func advanceTimer(timer: Timer) {
        currentTime = Date().timeIntervalSinceReferenceDate - startTime
        if lowSpeed < highSpeed {
            checkForDragTime()
        }
    }
    
    @objc func advanceSpeedometerTimer(timer: Timer) {
            speedo.animateCircle(duration: 1.0,
                                 currentSpeed: currentSpeed,
                                 maxSpeed: maxSpeed,
                                 highSpeed: highSpeed,
                                 lowSpeed: lowSpeed,
                                 speedTypeCoefficient: speedTypeCoefficient)
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
    
    func refreshAllLabels() {
        DispatchQueue.main.async(execute:  {
            self.speedReplacementLabel.text = "\(self.convertedCurrentSpeed)"
            self.maxSpeedLabel.text = "Max: \(self.convertedMaxSpeed) "
            self.accuracyLabel.text = "\(self.currentHorizontalAccuracy) m"
            self.accelerationLabel.text = "\(self.currentGForce) g"
            self.timeReplacementLabel.text = "\(self.dragTime) s"
        })
    }
    
    func updateSpeedGraph() {
        
        var lineChartEntriesSpeed = [ChartDataEntry]()
        var lineChartEntriesDrag = [ChartDataEntry]()
        var lineChartEntriesHeight = [ChartDataEntry]()
        
        let maxSpeed = speedLog.max(by: {$0.1 < $1.1 })!.1
        let minSpeed = speedLog.min(by: {$0.1 < $1.1 })!.1
        let maxHeight = heightLog.max(by: {$0.1 < $1.1 })!.1
        let minHeight = heightLog.min(by: {$0.1 < $1.1 })!.1
        
        for i in 0..<self.speedLog.count {
            let speed = speedLog[i].1*speedTypeCoefficient
            var speedNormalized = Double()
            if maxSpeed == minSpeed { speedNormalized = 0.0 }
            else { speedNormalized = (speed-minSpeed)/(maxSpeed-minSpeed) }
            let value = ChartDataEntry(x: speedLog[i].0, y: speedNormalized)
            lineChartEntriesSpeed.insert(value, at: 0)
        }
        
        let dragLogLength = self.dragLog.count
        for i in 0..<dragLogLength {
            let speed = dragLog[dragLogLength-i-1].1*speedTypeCoefficient
            var speedNormalized = Double()
            if maxSpeed == minSpeed { speedNormalized = 0.0 }
            else { speedNormalized = (speed-minSpeed)/(maxSpeed-minSpeed) }
            let value = ChartDataEntry(x: dragLog[dragLogLength-i-1].0, y: speedNormalized)
            lineChartEntriesDrag.insert(value, at: 0)
        }
        
        for i in 0..<self.heightLog.count {
            let height = self.heightLog[i].1
            var heightNormalized = Double()
            if maxHeight == minHeight { heightNormalized = 0.0 }
            else { heightNormalized = (height-minHeight)/(maxHeight-minHeight) }
            let value = ChartDataEntry(x: heightLog[i].0, y: heightNormalized)
            lineChartEntriesHeight.insert(value, at: 0)
        }
        
        
        let speedLine = LineChartDataSet(values: lineChartEntriesSpeed, label: nil)
        speedLine.drawCirclesEnabled = false
        speedLine.mode = LineChartDataSet.Mode.horizontalBezier
        speedLine.lineWidth = 5.0
        speedLine.drawFilledEnabled = true
        speedLine.fill = Fill(CGColor: Constants.graphColor.cgColor as CGColor)
        speedLine.colors = [Constants.graphColor]
        
        let dragLine = LineChartDataSet(values: lineChartEntriesDrag, label: nil)
        dragLine.drawCirclesEnabled = false
        dragLine.mode = LineChartDataSet.Mode.horizontalBezier
        dragLine.lineWidth = 5.0
        dragLine.drawFilledEnabled = false
        dragLine.fill = Fill(CGColor: Constants.graphColor.cgColor as CGColor)
        dragLine.colors = [Constants.graphColor]
        
        let heightLine = LineChartDataSet(values: lineChartEntriesHeight, label: nil)
        heightLine.drawCirclesEnabled = false
        heightLine.mode = LineChartDataSet.Mode.horizontalBezier
        heightLine.lineWidth = 1.0
        heightLine.drawFilledEnabled = true
        heightLine.fill = Fill(CGColor: Constants.graphColor.cgColor as CGColor)
        heightLine.colors = [Constants.graphColor]
        
        let data = LineChartData()
        
        data.addDataSet(speedLine)
        data.addDataSet(dragLine)
        data.addDataSet(heightLine)
        
        data.setDrawValues(false)
        
        speedLogChart.data = data
        self.speedLogChart.notifyDataSetChanged()
        
    }
    
    func fireConnectionNotification(title: String, subtitle: String, connection: Bool, backgroundColor: UIColor) {
        if !notificationFired {
            banner.dismiss()
            banner = Banner(title: title, subtitle: subtitle, image: UIImage(named: "gpsIcon"), backgroundColor: backgroundColor)
            banner.dismissesOnTap = true
            banner.position = BannerPosition.bottom
            if connection {
                if !connectionEstablishedNotificationFired {
                    banner.show(duration: 3.0)
                    noConnectionNotificationFired = false
                    connectionEstablishedNotificationFired = true
                }
            }
            else {
                if !noConnectionNotificationFired {
                    accuracyLabel.text = "n/a"
                    speedReplacementLabel.text = "n/a"
                    accelerationLabel.text = "n/a"
                    banner.show()
                    speedo.animateCircle(duration: 3.0,
                                         currentSpeed: 100,
                                         maxSpeed: 100,
                                         highSpeed: 100,
                                         lowSpeed: 0,
                                         speedTypeCoefficient: speedTypeCoefficient)
                    noConnectionNotificationFired = true
                    connectionEstablishedNotificationFired = false
                }
            }
            notificationFired = true
            let delayInSeconds = 5.0
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                self.notificationFired = false
            }
        }
    }
    
    func saveCurrentTime() {
        var measurements = [Measurement]()
        if let decoded = UserDefaults.standard.object(forKey: "measurements") as? NSData {
            let array = NSKeyedUnarchiver.unarchiveObject(with: decoded as Data) as! [Measurement]
            measurements = array
        }
        let currentDate = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .medium, timeStyle: .short)
        let currentMeasurement = Measurement(time: dragTime,
                                             speedLog: speedLog,
                                             heightLog: heightLog,
                                             accelerationLog: accelerationLog,
                                             lowSpeed: lowSpeed,
                                             highSpeed: highSpeed,
                                             speedTypeCoefficient: speedTypeCoefficient,
                                             speedType: speedType,
                                             date: currentDate)
        measurements += [currentMeasurement]
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: measurements)
        UserDefaults.standard.set(encodedData, forKey: "measurements")
    }
    
    @objc func speedLogPressed(_ sender:UITapGestureRecognizer) {
        if speedLog.count > 0 {
            performSegue(withIdentifier: "showSpeedLogDetail", sender: self)
        }
    }
    
    @objc func heightLogPressed(_ sender:UITapGestureRecognizer) {
        if heightLog.count > 0 {
            performSegue(withIdentifier: "showHeightLogDetail", sender: self)
        }
    }
    
    @objc func accelerationLogPressed(_ sender:UITapGestureRecognizer) {
        if accelerationLog.count > 0 {
            performSegue(withIdentifier: "showAccelerationLogDetail", sender: self)
        }
    }
    
    @IBAction func savedMeasurementsButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "showSavedMeasurements", sender: self)
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showSettings", sender: self)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        saveCurrentTime()
    }
    
    @IBAction func highSpeedField(_ sender: UITextField) {
        if let input = Double(sender.text!) {
            if input > lowSpeed {
                highSpeed = input
            }
        }
        highSpeedField.text = String(highSpeed)
    }
    
    @IBAction func lowSpeedField(_ sender: UITextField) {
        if let input = Double(sender.text!) {
            if input < highSpeed {
                lowSpeed = input
            }
        }
        lowSpeedField.text = String(lowSpeed)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSettings" {
            let vc = segue.destination as! SettingsController
            vc.previousViewController = self
            vc.drawRange = self.drawRange
            vc.speedTypeCoefficient = self.speedTypeCoefficient
            vc.speedType = self.speedType
        }
        if segue.identifier == "showSavedMeasurements" {
            let vc = segue.destination as! SavedMeasurementsController
            vc.previousViewController = self
        }
    }


}

