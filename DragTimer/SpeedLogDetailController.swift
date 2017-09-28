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
    
//    @IBOutlet weak var speedLogChart: LineChartView!
//    @IBOutlet weak var speedLogChartBackground: UIView!
//    @IBOutlet weak var navigationBar: UINavigationBar!
    
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var speedLogChart: LineChartView!
    @IBOutlet weak var speedLogChartBackground: UIView!
    
    let gradientLayer = CAGradientLayer()
    
    var speedLog = [(Double, Double)]()
    var speedType = String()
    var speedTypeCoefficient = Double()
    var drawRange = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInterfaceDesign()
        updateSpeedGraph()
    }
    
    func setUpInterfaceDesign() {

        self.view.addSubview(navigationBar)
        let navigationItem = UINavigationItem(title: "Detail View")
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector (self.closeButtonPressed (_:)))
        doneItem.tintColor = Constants.designColor1
        navigationItem.rightBarButtonItem = doneItem
        navigationBar.setItems([navigationItem], animated: false)
        
        self.speedLogChartBackground.layer.cornerRadius = 10.0

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
        
        for i in 0..<self.speedLog.count {
            let value = ChartDataEntry(x: speedLog[i].0, y: self.speedLog[i].1*self.speedTypeCoefficient)
            lineChartEntriesSpeed.insert(value, at: 0)
        }
        
        
        let speedLine = LineChartDataSet(values: lineChartEntriesSpeed, label: "Speed (in "+self.speedType+")")
        speedLine.drawCirclesEnabled = false
        speedLine.mode = LineChartDataSet.Mode.horizontalBezier
        speedLine.lineWidth = 2.0
        speedLine.drawFilledEnabled = true
        speedLine.colors = [Constants.designColor1,
                            Constants.designColor2]
        
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
    
    @objc func closeButtonPressed(_ sender:UITapGestureRecognizer){
        performSegueToReturnBack()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    

    
}

