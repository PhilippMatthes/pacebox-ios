//
//  HeightLogDetailController.swift
//  DragTimer
//
//  Created by Philipp Matthes on 17.09.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import UIKit
import Charts
import CoreLocation

class HeightLogDetailController: UIViewController, ChartViewDelegate {
    
    
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var heightLogChartBackground: UIView!
    @IBOutlet weak var heightLogChart: LineChartView!
    
    var previousViewController = ViewController()
    
    let gradientLayer = CAGradientLayer()
    
    var heightLog = [(Double, Double)]()
    var drawRange = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInterfaceDesign()
        updateHeightGraph()
    }
    
    func setUpInterfaceDesign() {
        
        self.view.addSubview(navigationBar)
        let navigationItem = UINavigationItem(title: "Detail View")
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector (self.closeButtonPressed (_:)))
        doneItem.tintColor = UIColor.orange
        navigationItem.rightBarButtonItem = doneItem
        navigationBar.setItems([navigationItem], animated: false)
        
        self.heightLogChartBackground.layer.cornerRadius = 10.0
        
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
    
    func updateHeightGraph() {
        
        var lineChartEntriesHeight = [ChartDataEntry]()
        
        for i in 0..<self.heightLog.count {
            let value = ChartDataEntry(x: heightLog[i].0, y: self.heightLog[i].1)
            lineChartEntriesHeight.insert(value, at: 0)
        }
        
        let heightLine = LineChartDataSet(values: lineChartEntriesHeight, label: "Height in m")
        heightLine.drawCirclesEnabled = false
        heightLine.mode = LineChartDataSet.Mode.horizontalBezier
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
        self.heightLogChart.rightAxis.enabled = false
        
    }
    
    @objc func closeButtonPressed(_ sender:UITapGestureRecognizer){
        performSegueToReturnBack()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func performSegueToReturnBack()  {
        previousViewController.startTimer()
        previousViewController.startSpeedometer()
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
}


