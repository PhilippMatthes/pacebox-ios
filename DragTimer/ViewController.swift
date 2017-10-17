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
//import GoogleMobileAds

class ViewController: UIViewController, CLLocationManagerDelegate, ChartViewDelegate, CAAnimationDelegate, UIGestureRecognizerDelegate {
    
    
    // MARK: Outlets
    
    @IBOutlet weak var accuracyConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var accelerationConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var settingsConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var speedTypeLabel: UILabel!
    @IBOutlet weak var speedometerView: UIView!
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
    @IBOutlet weak var timeIndicationLabel: UILabel!
    
    // MARK: Variables
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
    var weight = Double()
    var weightType = String()
    var weightTypeCoefficient = Double()
    weak var timer: Timer?
    weak var speedometerTimer: Timer?
    weak var visualTimer: Timer?
    var startTime: Double = 0
    var currentTime: Double = 0
    var updateGraphs = Bool()
    var dragTime = Double()
    var correctedDragTime = Double()
    var notificationFired = false
    var connectionEstablishedNotificationFired = false
    var noConnectionNotificationFired = false
    var currentMeasurement: Measurement?
    var currentMeasurementIdentifier = Int()
    var banner = Banner()
    let gradientLayer = CAGradientLayer()
    var motionManager = CMMotionManager()
    var hudViewActive = false
    var currentTimeIndication = 0.00
    var visualTimerIsRunning = false
    var previousSpeed = 0.0
    var speedLogDataAvailable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
        currentMeasurementIdentifier = countSavedMeasurements()
        loadSettings()
        setUpSpeedometer()
        setUpLocationManager()
        setUpInterfaceDesign()
        setUpBackground(frame: self.view.bounds)
        setUpChartView()
        startTimer()
        startSpeedometer()
        setUpMotionManager()
    }
    
//    func shouldShowAds() -> Bool {
//        let showAdsDate = UserDefaults.standard.object(forKey: "showAdsDate") as? Date ?? Date()
//        let timeFromDate = showAdsDate.seconds(from: Date())
//        if timeFromDate > 0 {
//            return false
//        }
//        else {
//            return true
//        }
//    }
    
    func setUpNoAdView() {
        bannerView.isHidden = true
        accuracyConstraint.constant = 8.0
        settingsConstraint.constant = 8.0
        accelerationConstraint.constant = 8.0
    }
    
//    func setUpAdView() {
//        accuracyConstraint.constant = 58.0
//        settingsConstraint.constant = 58.0
//        accelerationConstraint.constant = 58.0
//        bannerView.isHidden = false
//        self.view.addSubview(bannerView)
//        bannerView.adUnitID = "ca-app-pub-5941274384378366/3140722486"
//        bannerView.rootViewController = self
//        let requestAd: GADRequest = GADRequest()
////        requestAd.testDevices = [kGADSimulatorID]
//        bannerView.load(requestAd)
//
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateGraphs = false
        timer?.invalidate()
        speedometerTimer?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateGraphs = true
//        let showAds = shouldShowAds()
        setUpNoAdView()
//        if showAds {
//            setUpAdView()
//        }
//        else {
//            setUpNoAdView()
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func loadSettings() {
        lowSpeed = UserDefaults.standard.object(forKey: "lowSpeed") as? Double ?? 0.0
        highSpeed = UserDefaults.standard.object(forKey: "highSpeed") as? Double ?? 100.0
        speedType = UserDefaults.standard.object(forKey: "speedType") as? String ?? "km/h"
        speedTypeCoefficient = UserDefaults.standard.object(forKey: "speedTypeCoefficient") as? Double ?? 3.6
        weight = UserDefaults.standard.object(forKey: "weight") as? Double ?? 1500.0
        weightType = UserDefaults.standard.object(forKey: "weightType") as? String ?? "kg"
        weightTypeCoefficient = UserDefaults.standard.object(forKey: "weightTypeCoefficient") as? Double ?? 1.0
        drawRange = UserDefaults.standard.object(forKey: "speedTypeCoefficient") as? Int ?? 120
        speedTypeLabel.text = speedType        
    }
    
    func setUpSpeedometer() {
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
        self.timeIndicationLabel.textColor = UIColor.white
        let backgrounds = [settingsBackground,
                           accuracyBackground,
                           accelerationBackground,
                           timeBackground,
                           savedMeasurementsButtonBackground,
                           saveButtonBackground]
        for background in backgrounds {
            background?.layer.cornerRadius = Constants.cornerRadius
//            background?.dropShadow(color: UIColor.black,
//                                   opacity: 0.3,
//                                   offSet: CGSize(),
//                                   radius: 7,
//                                   scale: true)
            background?.layer.backgroundColor = Constants.interfaceColor.cgColor
        }
    }

    func setUpBackground(frame: CGRect) {
        gradientLayer.frame = frame
        gradientLayer.colors = [Constants.backgroundColor1.cgColor as CGColor, 
                                Constants.backgroundColor2.cgColor as CGColor]
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
        speedLogChart.isHidden = true
        speedLogChart.alpha = 0.0
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
        if !speedLogDataAvailable {
            speedLogDataAvailable = true
            animateShow(view: speedLogChart)
        }
        previousSpeed = currentSpeed
        let speed = locations[0].speed
        if speed >= 0.0 {
            currentSpeed = speed
            updateGraphs = true
            fireConnectionNotification(title: "Connection established!",
                                       subtitle: nil,
                                       connection: true,
                                       backgroundColor: Constants.designColor1)
        }
        else {
            updateGraphs = false
            fireConnectionNotification(title: "No GPS Connection!",
                                       subtitle: nil,
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
    
    @objc func advanceTimer(timer: Timer) {
        currentTime = Date().timeIntervalSinceReferenceDate - startTime
        if lowSpeed < highSpeed {
            checkForDragTime()
        }
        if currentSpeed*speedTypeCoefficient > lowSpeed && currentSpeed*speedTypeCoefficient <= highSpeed {
            if !visualTimerIsRunning && previousSpeed*speedTypeCoefficient <= lowSpeed{
                startVisualTimer()
                visualTimerIsRunning = true
            }
        }
        else {
            if visualTimerIsRunning {
                stopVisualTimer()
                visualTimerIsRunning = false
            }
        }
    }
    
    func startVisualTimer() {
        currentTimeIndication = 0.00
        visualTimer = Timer.scheduledTimer(timeInterval: 0.07, target: self, selector: #selector(self.incrementVisualTimeLabel), userInfo: nil, repeats: true)
    }
    
    @objc func incrementVisualTimeLabel() {
        currentTimeIndication = Double(round((currentTimeIndication + 0.07) * 100)/100)
        self.timeIndicationLabel.text = String(currentTimeIndication) + " s"
    }
    
    func stopVisualTimer() {
        visualTimer?.invalidate()
        self.timeIndicationLabel.text = String(dragTime) + " s"
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
        var tempHeightLog = [(Double, Double)]()
        
        while !upperBoundFound || !lowerBoundFound {
            
            if currentIndex == speedLog.count {
                return
            }
            
            if speedLog[currentIndex].1 * speedTypeCoefficient >= highSpeed {
                while tempDragLog.count > 0 {
                    tempDragLog.remove(at: 0)
                    tempHeightLog.remove(at: 0)
                }
                upperBoundFound = true
            }
            
            if (speedLog[currentIndex].1 * speedTypeCoefficient <= lowSpeed) && upperBoundFound {
                lowerBoundFound = true
            }
            
            if upperBoundFound {
                tempDragLog.insert(speedLog[currentIndex], at: 0)
                tempHeightLog.insert(heightLog[currentIndex], at: 0)
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
        
        let estimatedTime = upperTime - lowerTime
        
        let h0 = tempHeightLog[0].1
        let h1 = tempHeightLog.popLast()!.1
        let hDelta = h1 - h0
        
        let ePotDelta = (weight/weightTypeCoefficient) * 9.81 * hDelta
        let eKin0 = 0.5 * (weight/weightTypeCoefficient) * pow(lowSpeed, 2)
        let eKin1 = 0.5 * (weight/weightTypeCoefficient) * pow(highSpeed, 2)
        let eKinDelta = eKin1 - eKin0
        
        let estimatedCorrectedTime = ((eKinDelta - ePotDelta) / (eKinDelta)) * estimatedTime
        
        if !estimatedTime.isNaN && !estimatedCorrectedTime.isNaN {
            dragTime = Double(round(100 * estimatedTime)/100)
            correctedDragTime = Double(round(100 * estimatedCorrectedTime)/100)
            refreshAllLabels()
            updateCurrentMeasurement()
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
            if (self.dragTime == 0.0) {
                self.timeReplacementLabel.text = "n/a (n/a)"
            }
            else {
                self.timeReplacementLabel.text = "\(self.dragTime)s (\(self.correctedDragTime)s)"
                self.timeIndicationLabel.text = "\(self.dragTime) s"
            }
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
        speedLine.lineWidth = 3.0
        speedLine.drawFilledEnabled = true
        speedLine.fill = Fill(CGColor: Constants.graphColor.cgColor as CGColor)
        speedLine.colors = [Constants.graphColor]
        
        let dragLine = LineChartDataSet(values: lineChartEntriesDrag, label: nil)
        dragLine.drawCirclesEnabled = false
        dragLine.mode = LineChartDataSet.Mode.horizontalBezier
        dragLine.lineWidth = 3.0
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
    
    func fireConnectionNotification(title: String, subtitle: String?, connection: Bool, backgroundColor: UIColor) {
        if !notificationFired && !hudViewActive {
            banner.dismiss()
            banner = Banner(title: title, subtitle: subtitle, image: UIImage(named: "gpsIcon"), backgroundColor: backgroundColor)
            banner.titleLabel.font = Constants.font
            banner.dismissesOnTap = true
            banner.position = BannerPosition.top
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
    
    func fireNoMeasurementNotification() {
        banner.dismiss()
        banner = Banner(title: "No time recorded yet.", subtitle: nil, image: UIImage(named: "ListIcon"), backgroundColor: Constants.designColor1)
        banner.titleLabel.font = Constants.font
        banner.dismissesOnTap = true
        banner.position = BannerPosition.top
        banner.show(duration: 2.0)
    }
    
    func fireTimeSavedNotification() {
        banner.dismiss()
        banner = Banner(title: "Time saved.", subtitle: nil, image: UIImage(named: "CheckIcon"), backgroundColor: Constants.designColor2)
        banner.titleLabel.font = Constants.font
        banner.dismissesOnTap = true
        banner.position = BannerPosition.top
        banner.show(duration: 2.0)
    }
    
    func countSavedMeasurements() -> Int {
        if let decoded = UserDefaults.standard.object(forKey: "measurements") as? NSData {
            let array = NSKeyedUnarchiver.unarchiveObject(with: decoded as Data) as! [Measurement]
            return array.count
        }
        return 0
    }
    
    func saveCurrentTime() {
        if let _ = currentMeasurement {
            var measurements = [Measurement]()
            if let decoded = UserDefaults.standard.object(forKey: "measurements") as? NSData {
                let array = NSKeyedUnarchiver.unarchiveObject(with: decoded as Data) as! [Measurement]
                measurements = array
            }
        
            measurements += [currentMeasurement!]
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: measurements)
            UserDefaults.standard.set(encodedData, forKey: "measurements")
            fireTimeSavedNotification()
        }
        else {
            fireNoMeasurementNotification()
        }
    }
    
    func updateCurrentMeasurement() {
        currentMeasurementIdentifier += 1
        let currentDate = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .medium, timeStyle: .short)
        currentMeasurement = Measurement(identifier: String(currentMeasurementIdentifier),
                                             time: dragTime,
                                             correctedTime: self.correctedDragTime,
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
                                             date: currentDate,
                                             drawRange: drawRange)
        
    }
    
    
    @IBAction func savedMeasurementsButtonPressed(_ sender: UIButton) {
        animateButtonReleaseOff(background: savedMeasurementsButtonBackground)
        performSegue(withIdentifier: "showSavedMeasurements", sender: self)
    }
    

    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "showSettings", sender: self)
        animateButtonReleaseOff(background: settingsBackground)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        animateButtonReleaseOff(background: saveButtonBackground)
        saveCurrentTime()
    }
    
    @IBAction func saveButtonTouchDown(_ sender: UIButton) {
        animateButtonPressOn(background: saveButtonBackground)
    }
    
    @IBAction func listButtonTouchDown(_ sender: UIButton) {
        animateButtonPressOn(background: savedMeasurementsButtonBackground)
    }
    
    
    @IBAction func highSpeedTouchDown(_ sender: UITextField) {
        animateButtonPressOn(background: sender)
    }
    
    
    @IBAction func lowSpeedTouchDown(_ sender: UITextField) {
        animateButtonPressOn(background: sender)
    }
    
    @IBAction func settingsButtonTouchDown(_ sender: UIButton) {
        animateButtonPressOn(background: settingsBackground)
    }
    
    func animateButtonPressOn(background: UIView) {
        let borderWidth:CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
        borderWidth.fromValue = 0
        borderWidth.toValue = 3.0
        borderWidth.duration = 0.1
        background.layer.borderWidth = 0.0
        background.layer.borderColor = Constants.designColor1.cgColor as CGColor
        background.layer.add(borderWidth, forKey: "Width")
        background.layer.borderWidth = 3.0
    }
    
    func animateButtonReleaseOff(background: UIView) {
        let borderWidth:CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
        borderWidth.fromValue = 3.0
        borderWidth.toValue = 0
        borderWidth.duration = 0.1
        background.layer.borderWidth = 3.0
        background.layer.borderColor = Constants.designColor1.cgColor as CGColor
        background.layer.add(borderWidth, forKey: "Width")
        background.layer.borderWidth = 0.0
    }
    

    
    
    
    @IBAction func userSwipedLeft(_ sender: UISwipeGestureRecognizer) {
        if !hudViewActive {
            animateHide(view: speedLogChart)
            animateHide(view: timeBackground)
            animateHide(view: accuracyBackground)
            animateHide(view: settingsBackground)
            animateHide(view: saveButtonBackground)
            animateHide(view: savedMeasurementsButtonBackground)
            animateHide(view: accelerationBackground)
            animateHide(view: accuracyLabel)
            animateHide(view: timeReplacementLabel)
            animateHide(view: timeIndicationLabel)
            animateHide(view: accelerationLabel)
            animateHide(view: maxSpeedLabel)
//            if shouldShowAds() {
//                animateHide(view: bannerView)
//            }
            var transform = CGAffineTransform.identity
            transform = transform.rotated(by: -CGFloat(Double.pi)/2)
            transform = transform.scaledBy(x: -1, y: 1)
            UIView.animate(withDuration: 0.2, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
                self.speedometerView.transform = transform
            }, completion: nil)
            animateBackground(fromColors: [Constants.backgroundColor1.cgColor as CGColor,
                                           Constants.backgroundColor2.cgColor as CGColor],
                              toColors: [Constants.backgroundColorDark1.cgColor as CGColor,
                                         Constants.backgroundColorDark2.cgColor as CGColor], duration: 1.0)
            hudViewActive = true
        }
        else {
            switchToNormalView()
        }
    }
    
    @IBAction func userSwipedRight(_ sender: UISwipeGestureRecognizer) {
        if !hudViewActive {
            animateHide(view: speedLogChart)
            animateHide(view: timeBackground)
            animateHide(view: accuracyBackground)
            animateHide(view: settingsBackground)
            animateHide(view: saveButtonBackground)
            animateHide(view: savedMeasurementsButtonBackground)
            animateHide(view: accelerationBackground)
            animateHide(view: accuracyLabel)
            animateHide(view: timeReplacementLabel)
            animateHide(view: timeIndicationLabel)
            animateHide(view: accelerationLabel)
            animateHide(view: maxSpeedLabel)
//            if shouldShowAds() {
//                animateHide(view: bannerView)
//            }
            var transform = CGAffineTransform.identity
            transform = transform.rotated(by: CGFloat(Double.pi)/2)
            transform = transform.scaledBy(x: -1, y: 1)
            UIView.animate(withDuration: 0.2, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
                self.speedometerView.transform = transform
            }, completion: nil)
            animateBackground(fromColors: [Constants.backgroundColor1.cgColor as CGColor,
                                           Constants.backgroundColor2.cgColor as CGColor],
                              toColors: [Constants.backgroundColorDark1.cgColor as CGColor,
                                         Constants.backgroundColorDark2.cgColor as CGColor], duration: 1.0)
            hudViewActive = true
        }
        else {
            switchToNormalView()
        }
    }
    
    
    
    func switchToNormalView() {
        if hudViewActive {
//            if shouldShowAds() {
//                animateShow(view: bannerView)
//            }
            animateShow(view: speedLogChart)
            animateShow(view: timeBackground)
            animateShow(view: accuracyBackground)
            animateShow(view: settingsBackground)
            animateShow(view: saveButtonBackground)
            animateShow(view: savedMeasurementsButtonBackground)
            animateShow(view: accelerationBackground)
            animateShow(view: accuracyLabel)
            animateShow(view: timeReplacementLabel)
            animateShow(view: timeIndicationLabel)
            animateShow(view: accelerationLabel)
            animateShow(view: maxSpeedLabel)
            var transform = CGAffineTransform.identity
            transform = transform.rotated(by: 0)
            transform = transform.scaledBy(x: 1, y: 1)
            UIView.animate(withDuration: 0.2, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
                self.speedometerView.transform = transform
            }, completion: nil)
            animateBackground(fromColors: [Constants.backgroundColorDark1.cgColor as CGColor,
                                           Constants.backgroundColorDark2.cgColor as CGColor],
                              toColors: [Constants.backgroundColor1.cgColor as CGColor,
                                         Constants.backgroundColor2.cgColor as CGColor], duration: 1.0)
            hudViewActive = false
        }
    }
    
    func animateBackground(fromColors: [CGColor], toColors: [CGColor], duration: CFTimeInterval){
        
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "colors")
        
        animation.fromValue = fromColors
        animation.toValue = toColors
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.delegate = self
        
        self.gradientLayer.add(animation, forKey: "animateGradient")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSettings" {
            let vc = segue.destination as! SettingsController
            vc.previousViewController = self
        }
        if segue.identifier == "showSavedMeasurements" {
            let vc = segue.destination as! SavedMeasurementsController
            vc.previousViewController = self
        }
    }
    
    func animateHide(view: UIView) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
            view.alpha = 0
        }, completion: { _ in
            view.isHidden = true
        })
    }
    
    func animateShow(view: UIView) {
        view.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
            view.alpha = 1
        }, completion: nil)
    }
    

}

extension UIView {
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}

