//
//  SettingsController.swift
//  DragTimer
//
//  Created by Philipp Matthes on 18.09.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit

class SettingsController: UIViewController {
    
    @IBOutlet weak var speedTypeButtonBackground: UIView!
    
    @IBOutlet weak var speedTypeButton: UIButton!
    @IBOutlet weak var speedTypeBackground: UIView!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var logSizeBackground: UIView!
    @IBOutlet weak var logSizeSlider: UISlider!
    @IBOutlet weak var logSizeSliderBackground: UIView!
    @IBOutlet weak var logSizeSliderLabel: UILabel!
    
    var previousViewController = ViewController()
    
    let gradientLayer = CAGradientLayer()
    
    var speedType = String()
    var speedTypeCoefficient = Double()
    var drawRange = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInterfaceDesign()
    }
    
    func setUpInterfaceDesign() {
        
        self.speedTypeButtonBackground.layer.cornerRadius = 10.0
        self.speedTypeBackground.layer.cornerRadius = 10.0
        self.logSizeBackground.layer.cornerRadius = 10.0
        self.logSizeSliderBackground.layer.cornerRadius = 10.0
        
        self.view.addSubview(navigationBar)
        let navigationItem = UINavigationItem(title: "Settings")
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector (self.closeButtonPressed (_:)))
        doneItem.tintColor = UIColor.orange
        navigationItem.rightBarButtonItem = doneItem
        navigationBar.setItems([navigationItem], animated: false)
        
        logSizeSlider.tintColor = UIColor.orange
        
        setUpBackground(frame: self.view.bounds)
        
        refreshAllLabels()
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
    
    @objc func closeButtonPressed(_ sender:UITapGestureRecognizer){
        performSegueToReturnBack()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func refreshAllLabels() {
        speedTypeButton.setTitle(speedType, for: .normal)
        logSizeSliderLabel.text = String(drawRange)
        logSizeSlider.value = Float(drawRange)
    }

    
    @IBAction func speedTypeButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(
                    title: "Units selection",
                    message: nil,
                    preferredStyle: UIAlertControllerStyle.actionSheet
                )
        
                let speedTypeKphAction = UIAlertAction (
                    title: "Metric (km/h)",
                    style: UIAlertActionStyle.default
                ) {
                    (action) -> Void in
                    self.speedType = "km/h"
                    self.speedTypeCoefficient = 3.6
                    self.refreshAllLabels()
                }
        
                let speedTypeMphAction = UIAlertAction (
                    title: "Imperialistic (mph)",
                    style: UIAlertActionStyle.default
                ) {
                    (action) -> Void in
                    self.speedType = "mph"
                    self.speedTypeCoefficient = 2.23694
                    self.refreshAllLabels()
                }
        
                let speedTypeMpsAction = UIAlertAction (
                    title: "Native (m/s)",
                    style: UIAlertActionStyle.default
                ) {
                    (action) -> Void in
                    self.speedType = "m/s"
                    self.speedTypeCoefficient = 1.0
                    self.refreshAllLabels()
                }
        
                let speedTypeKnotsAction = UIAlertAction (
                    title: "Aeronautical (kn)",
                    style: UIAlertActionStyle.default
                ) {
                    (action) -> Void in
                    self.speedType = "kn"
                    self.speedTypeCoefficient = 1.94384
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
                alertController.addAction(speedTypeMpsAction)
                alertController.addAction(speedTypeKnotsAction)
                alertController.addAction(cancelButtonAction)
                
                let popOver = alertController.popoverPresentationController
                popOver?.sourceView = sender as UIView
                popOver?.sourceRect = (sender as UIView).bounds
                popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
                
                self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func logSizeSliderValueChanged(_ sender: UISlider) {
        drawRange = Int(sender.value)
        refreshAllLabels()
    }
    
    func performSegueToReturnBack()  {
        previousViewController.startTimer()
        previousViewController.drawRange = drawRange
        previousViewController.speedTypeCoefficient = speedTypeCoefficient
        previousViewController.speedType = speedType
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
            
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
}

