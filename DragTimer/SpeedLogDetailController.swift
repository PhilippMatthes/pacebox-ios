//
//  speedLogDetailController.swift
//  DragTimer
//
//  Created by Philipp Matthes on 17.09.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import UIKit
import Charts
import CoreLocation

class SpeedLogDetailController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var dataBackground: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var speedLogChart: LineChartView!
    @IBOutlet weak var speedLogChartBackground: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var dragTimeLabel: UILabel!
    @IBOutlet weak var correctedDragTimeLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var averageAccelerationLabel: UILabel!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var heightDeltaLabel: UILabel!
    
    let gradientLayer = CAGradientLayer()
    
    var time: Double?
    var correctedTime: Double?
    var speedLog = [(Double, Double)]()
    var heightLog = [(Double, Double)]()
    var accelerationLog = [(Double, Double)]()
    var dragLog = [(Double, Double)]()
    var lowSpeed: Double?
    var highSpeed: Double?
    var speedTypeCoefficient: Double?
    var speedType: String?
    var weight: Double?
    var weightType: String?
    var weightTypeCoefficient: Double?
    var date: String?
    var drawRange: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInterfaceDesign()
        updateSpeedGraph()
        updateLabels()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func setUpInterfaceDesign() {

        self.view.addSubview(navigationBar)
        let navigationItem = UINavigationItem(title: "Detail View")
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector (self.closeButtonPressed (_:)))
        doneItem.tintColor = Constants.designColor1
        navigationItem.rightBarButtonItem = doneItem
        navigationBar.setItems([navigationItem], animated: false)
        
        let backgrounds = [speedLogChartBackground,
                           dataBackground]
        
        for background in backgrounds {
            background?.layer.cornerRadius = Constants.cornerRadius
//            background?.dropShadow(color: UIColor.black,
//                                   opacity: 0.3,
//                                   offSet: CGSize(),
//                                   radius: 7,
//                                   scale: true)
            background?.layer.backgroundColor = Constants.interfaceColor.cgColor
        }
        
        speedLogChart.delegate = self
        speedLogChart.chartDescription?.text = nil
        speedLogChart.leftAxis.axisMinimum = 0
        speedLogChart.rightAxis.enabled = false
        speedLogChart.leftAxis.enabled = true
        speedLogChart.xAxis.enabled = true
        speedLogChart.drawBordersEnabled = true
        speedLogChart.legend.enabled = true
        speedLogChart.legend.textColor = UIColor.gray
        speedLogChart.isUserInteractionEnabled = true

        setUpBackground(frame: self.view.bounds)
    }
    
    func setUpBackground(frame: CGRect) {
        gradientLayer.frame = frame
        gradientLayer.colors = [Constants.backgroundColor1.cgColor as CGColor,
                                Constants.backgroundColor2.cgColor as CGColor]
        gradientLayer.locations = [0.0, 1.0]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSpeedGraph() {
        
        
        var lineChartEntriesSpeed = [ChartDataEntry]()
        var lineChartEntriesDrag = [ChartDataEntry]()
//        var lineChartEntriesHeight = [ChartDataEntry]()
        
        let maxSpeed = speedLog.max(by: {$0.1 < $1.1 })!.1
        let minSpeed = speedLog.min(by: {$0.1 < $1.1 })!.1
        
        for i in 0..<self.speedLog.count {
            let speed = speedLog[i].1*speedTypeCoefficient!
            var speedNormalized = Double()
            if maxSpeed == minSpeed { speedNormalized = 0.0 }
            else { speedNormalized = (speed-minSpeed)/(maxSpeed-minSpeed) }
            let value = ChartDataEntry(x: speedLog[i].0, y: speedNormalized)
            lineChartEntriesSpeed.insert(value, at: 0)
        }
        
        let dragLogLength = self.dragLog.count
        for i in 0..<dragLogLength {
            let speed = dragLog[dragLogLength-i-1].1*speedTypeCoefficient!
            var speedNormalized = Double()
            if maxSpeed == minSpeed { speedNormalized = 0.0 }
            else { speedNormalized = (speed-minSpeed)/(maxSpeed-minSpeed) }
            let value = ChartDataEntry(x: dragLog[dragLogLength-i-1].0, y: speedNormalized)
            lineChartEntriesDrag.insert(value, at: 0)
        }
        
//        for i in 0..<self.heightLog.count {
//            let height = self.heightLog[i].1
//            let value = ChartDataEntry(x: heightLog[i].0, y: height)
//            lineChartEntriesHeight.insert(value, at: 0)
//        }
        
        
        let speedLine = LineChartDataSet(values: lineChartEntriesSpeed, label: "Speed in "+speedType!)
        speedLine.drawCirclesEnabled = false
        speedLine.mode = LineChartDataSet.Mode.horizontalBezier
        speedLine.lineWidth = 2.0
        speedLine.drawFilledEnabled = true
        speedLine.fill = Fill(CGColor: Constants.designColor1.cgColor as CGColor)
        speedLine.colors = [Constants.designColor1]
        
        let dragLine = LineChartDataSet(values: lineChartEntriesDrag, label: String(lowSpeed!)+" to "+String(highSpeed!)+" "+speedType!)
        dragLine.drawCirclesEnabled = false
        dragLine.mode = LineChartDataSet.Mode.horizontalBezier
        dragLine.lineWidth = 2.0
        dragLine.drawFilledEnabled = true
        dragLine.fill = Fill(CGColor: Constants.designColor2.cgColor as CGColor)
        dragLine.colors = [Constants.designColor2]
        
//        let heightLine = LineChartDataSet(values: lineChartEntriesHeight, label: "Height in m")
//        heightLine.drawCirclesEnabled = false
//        heightLine.mode = LineChartDataSet.Mode.horizontalBezier
//        heightLine.lineWidth = 1.0
//        heightLine.drawFilledEnabled = true
//        heightLine.fill = Fill(CGColor: UIColor.gray.cgColor as CGColor)
//        heightLine.colors = [UIColor.gray]
        
        let data = LineChartData()
        
        data.addDataSet(speedLine)
        data.addDataSet(dragLine)
//        data.addDataSet(heightLine)
        
        data.setDrawValues(false)
        
//        speedLogChart.animate(xAxisDuration: 2.0, easingOption: ChartEasingOption.easeInOutCubic)
        
        
        speedLogChart.data = data
        let xMax = dragLog.last!.0 + (dragLog.last!.0 - dragLog.first!.0) * 0.2
        var xMin = dragLog.first!.0 - (dragLog.last!.0 - dragLog.first!.0) * 0.2
        if xMin < 0 {
            xMin = 0
        }
        speedLogChart.setVisibleXRange(minXRange: xMin, maxXRange: xMax)
        self.speedLogChart.notifyDataSetChanged()
    }
    
    @objc func closeButtonPressed(_ sender:UITapGestureRecognizer){
        performSegueToReturnBack()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func updateLabels() {
        dateLabel.text = "Date: "+date!
        speedLabel.text = "Speed: "+String(lowSpeed!)+" to "+String(highSpeed!)+" "+speedType!
        dragTimeLabel.text = "Time: "+String(time!)+" s"
        correctedDragTimeLabel.text = "Corrected time: "+String(correctedTime!)+" s"
        let weightString = "Vehicle weight: "+String(Int(Double(round(100 * weight! * weightTypeCoefficient!)/100))) + " " + weightType!
        weightLabel.text = weightString
        var acceleration = 0.0
        for a in accelerationLog {
            acceleration += a.1
        }
        averageAccelerationLabel.text = "Average Acceleration: "+String(Double(round(100*acceleration/Double(accelerationLog.count))/100))
        let max = Double(round(100*speedLog.max(by: {$0.1 < $1.1 })!.1)/100)
        maxSpeedLabel.text = "Maximum Speed: "+String(Double(round(100*max*speedTypeCoefficient!)/100))+" "+speedType!
        let h0 = heightLog[0].1
        let h1 = heightLog.popLast()!.1
        let heightDelta = h1 - h0
        heightDeltaLabel.text = "Height delta: "+String(Double(round(100*heightDelta)/100))+" m"
    }
    
    
    @IBAction func userSwipedDown(_ sender: UISwipeGestureRecognizer) {
        performSegueToReturnBack()
    }
    
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    

    
}

