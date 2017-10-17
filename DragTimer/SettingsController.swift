//
//  SettingsController.swift
//  DragTimer
//
//  Created by Philipp Matthes on 18.09.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
//import GoogleMobileAds

class SettingsController: UIViewController{
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var speedTypeButtonBackground: UIView!
    
    @IBOutlet weak var uicolorSelectionBackground: UIView!
    @IBOutlet weak var speedTypeButton: UIButton!
    @IBOutlet weak var speedTypeBackground: UIView!
    
    @IBOutlet weak var weightBackground: UIView!
    @IBOutlet weak var rangeBackground: UIView!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var highSpeedField: UITextField!
    @IBOutlet weak var lowSpeedField: UITextField!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var logSizeBackground: UIView!
    @IBOutlet weak var logSizeSlider: UISlider!
    @IBOutlet weak var logSizeSliderBackground: UIView!
    @IBOutlet weak var logSizeSliderLabel: UILabel!
    
//    @IBOutlet weak var adBackground: UIView!
//    @IBOutlet weak var adButtonBackground: UIView!
//    @IBOutlet weak var adFreeTimeLabel: UILabel!
//    @IBOutlet weak var loadAdLabel: UILabel!
    
//    var rewardBasedVideo: GADRewardBasedVideoAd?
    
    var previousViewController = ViewController()
    
    let gradientLayer = CAGradientLayer()
    
//    var adWasReceived = false
    
//    weak var adTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()


        
        loadSettings()
        setUpDoneButton()
        setUpInterfaceDesign()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        adTimer?.invalidate()
    }
    
    func loadSettings() {
        lowSpeedField.text = String(previousViewController.lowSpeed)
        highSpeedField.text = String(previousViewController.highSpeed)
        weightField.text = String(Int(Double(round(100 * previousViewController.weight * previousViewController.weightTypeCoefficient)/100))) + " " + previousViewController.weightType
    }
    
    @IBAction func highSpeedField(_ sender: UITextField) {
        if let input = Double(sender.text!) {
            if input > previousViewController.lowSpeed {
                if input != previousViewController.highSpeed {
                    previousViewController.correctedDragTime = 0.0
                    previousViewController.dragTime = 0.0
                    previousViewController.timeReplacementLabel.text = "n/a (n/a)"
                    previousViewController.currentMeasurement = nil
                }
                previousViewController.highSpeed = input
            }
        }
        animateButtonReleaseOff(background: sender)
        highSpeedField.text = String(previousViewController.highSpeed)
        UserDefaults.standard.set(previousViewController.highSpeed, forKey: "highSpeed")
    }
    
    @IBAction func lowSpeedField(_ sender: UITextField) {
        if let input = Double(sender.text!) {
            if input < previousViewController.highSpeed {
                if input != previousViewController.lowSpeed {
                    previousViewController.correctedDragTime = 0.0
                    previousViewController.dragTime = 0.0
                    previousViewController.timeReplacementLabel.text = "n/a (n/a)"
                    previousViewController.currentMeasurement = nil
                }
                previousViewController.lowSpeed = input
            }
        }
        animateButtonReleaseOff(background: sender)
        lowSpeedField.text = String(previousViewController.lowSpeed)
        UserDefaults.standard.set(previousViewController.lowSpeed, forKey: "lowSpeed")
    }
    
    @IBAction func weightField(_ sender: UITextField) {
        if let input = Double(sender.text!) {
            if input > 0.0 {
                previousViewController.weight = Double(round(100 * input/previousViewController.weightTypeCoefficient)/100)
            }
        }
        animateButtonReleaseOff(background: sender)
        UserDefaults.standard.set(previousViewController.weight, forKey: "weight")
        weightField.text = String(Int(Double(round(100 * previousViewController.weight * previousViewController.weightTypeCoefficient)/100))) + " " + previousViewController.weightType
    }
    
    @IBAction func fieldTouchDown(_ sender: UITextField) {
        animateButtonPressOn(background: sender)
    }
    
//    func startTimer() {
//        adTimer = Timer.scheduledTimer(timeInterval: 1.0,
//                                     target: self,
//                                     selector: #selector(advanceAdTimer(timer:)),
//                                     userInfo: nil,
//                                     repeats: true)
//    }
    
//    @objc func advanceAdTimer(timer: Timer) {
//        refreshNoAdsLabel()
//    }
    
//    func receiveAd() {
//        rewardBasedVideo = GADRewardBasedVideoAd.sharedInstance()
//        rewardBasedVideo?.delegate = self
//        let request = GADRequest()
////        request.testDevices = [kGADSimulatorID]
//        rewardBasedVideo?.load(request,
//                               withAdUnitID: "ca-app-pub-5941274384378366/6654609430")
//    }
    
//    func presentAd() {
//        if rewardBasedVideo?.isReady == true {
//            rewardBasedVideo?.present(fromRootViewController: self)
//        }
//    }
    
    func setUpDoneButton() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: NSLocalizedString("done", comment: "Done"), style: UIBarButtonItemStyle.done, target: self, action: #selector(self.doneButtonAction))
        done.tintColor = Constants.designColor1
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.lowSpeedField.inputAccessoryView = doneToolbar
        self.highSpeedField.inputAccessoryView = doneToolbar
        self.weightField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        self.lowSpeedField.resignFirstResponder()
        self.highSpeedField.resignFirstResponder()
        self.weightField.resignFirstResponder()
    }
    
    func setUpInterfaceDesign() {
        
        let backgrounds = [speedTypeBackground,
                           logSizeBackground,
                           uicolorSelectionBackground,
                           weightBackground,
                           rangeBackground]
        
        let buttonBackgrounds = [logSizeSliderBackground,
                                 weightField,
                                 lowSpeedField,
                                 highSpeedField,
                                 speedTypeButtonBackground]
        
        for background in backgrounds {
            background?.layer.cornerRadius = Constants.cornerRadius
            background?.dropShadow(color: UIColor.black,
                                   opacity: 0.3,
                                   offSet: CGSize(),
                                   radius: 7,
                                   scale: true)
            background?.layer.backgroundColor = Constants.interfaceColor.cgColor
        }
        
        for background in buttonBackgrounds {
            background?.layer.cornerRadius = Constants.cornerRadius
//            background?.dropShadow(color: UIColor.black,
//                                   opacity: 1.0,
//                                   offSet: CGSize(),
//                                   radius: 3,
//                                   scale: true)
            background?.layer.backgroundColor = Constants.interfaceColor.cgColor
        }
        
        self.view.addSubview(navigationBar)
        let navigationItem = UINavigationItem(title: NSLocalizedString("settings", comment: "Settings"))
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector (self.closeButtonPressed (_:)))
        doneItem.tintColor = Constants.designColor1
        navigationItem.rightBarButtonItem = doneItem
        navigationBar.setItems([navigationItem], animated: false)
        
        logSizeSlider.tintColor = Constants.designColor1
        
        setUpBackground(frame: self.view.bounds)
        
//        let adClickRecognizer = UITapGestureRecognizer(target: self, action:  #selector (self.adButtonClicked(sender:)))
//        adButtonBackground.addGestureRecognizer(adClickRecognizer)
        
        refreshAllLabels()
    }
    
//    @objc func adButtonClicked(sender:UITapGestureRecognizer) {
//        animateButtonPressOn(background: adButtonBackground)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
//            self.animateButtonReleaseOff(background: self.adButtonBackground)
//        })
//        if !adWasReceived {
//            receiveAd()
//            showAdLoading()
//        }
//        else {
//            presentAd()
//            UIView.animate(withDuration: 0.3, animations: {
//                self.loadAdLabel.alpha = 0.0
//            })
//            loadAdLabel.text = "Load Ad"
//            UIView.animate(withDuration: 0.3, animations: {
//                self.loadAdLabel.alpha = 1.0
//            })
//            adWasReceived = false
//        }
//    }
    
//    func showAdLoading() {
//        UIView.animate(withDuration: 0.3, animations: {
//            self.loadAdLabel.alpha = 0.0
//        })
//        let alert = UIAlertController(title: nil, message: "Loading ad...", preferredStyle: .alert)
//
//        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
//        loadingIndicator.hidesWhenStopped = true
//        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//        loadingIndicator.startAnimating()
//
//        alert.view.addSubview(loadingIndicator)
//        present(alert, animated: true, completion: nil)
//    }
    
//    func loadingAdFinished() {
//        dismiss(animated: false, completion: nil)
//        self.loadAdLabel.text = "Play Ad"
//        UIView.animate(withDuration: 0.3, animations: {
//            self.loadAdLabel.alpha = 1.0
//        })
//        adWasReceived = true
//    }
    
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
    
    @objc func closeButtonPressed(_ sender:UITapGestureRecognizer){
        performSegueToReturnBack()
    }
    @IBAction func userSwipedDown(_ sender: UISwipeGestureRecognizer) {
        performSegueToReturnBack()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func refreshAllLabels() {
        speedTypeButton.setTitle(previousViewController.speedType + " - " + previousViewController.weightType, for: .normal)
        logSizeSliderLabel.text = String(previousViewController.drawRange)
        logSizeSlider.value = Float(previousViewController.drawRange)
//        refreshNoAdsLabel()
        weightField.text = String(Int(Double(round(100 * previousViewController.weight * previousViewController.weightTypeCoefficient)/100))) + " " + previousViewController.weightType
    }

//    func refreshNoAdsLabel() {
//        let showAdsDate = UserDefaults.standard.object(forKey: "showAdsDate") as? Date ?? Date()
//        let currentDate = Date()
//        let days = showAdsDate.days(from: currentDate)
//        let hours = showAdsDate.hours(from: currentDate) % 24
//        let minutes = showAdsDate.minutes(from: currentDate) % 60
//        let seconds = showAdsDate.seconds(from: currentDate) % 60
//        let time = showAdsDate.seconds(from: currentDate)
//        if time < 0 {
//            adFreeTimeLabel.text = "0d, 0h, 0min, 0s"
//        }
//        else {
//            adFreeTimeLabel.text = String(days)+"d, "+String(hours)+"h, "+String(minutes)+"min, "+String(seconds)+"s"
//        }
//    }
    

    
    
    @IBAction func speedTypeButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(
                    title: NSLocalizedString("unitsSelection", comment: "Units Selection"),
                    message: nil,
                    preferredStyle: UIAlertControllerStyle.actionSheet
                )
        
                let speedTypeKphAction = UIAlertAction (
                    title: NSLocalizedString("metric", comment: "Metric (km/h - kg)"),
                    style: UIAlertActionStyle.default
                ) {
                    (action) -> Void in
                    self.previousViewController.speedType = "km/h"
                    self.previousViewController.speedTypeCoefficient = 3.6
                    
                    self.previousViewController.weightType = "kg"
                    self.previousViewController.weightTypeCoefficient = 1.0
                    
                    self.refreshAllLabels()
                }
        
                let speedTypeMphAction = UIAlertAction (
                    title: NSLocalizedString("imperialistic", comment: "Imperialistic (mph - lbs)"),
                    style: UIAlertActionStyle.default
                ) {
                    (action) -> Void in
                    self.previousViewController.speedType = "mph"
                    self.previousViewController.speedTypeCoefficient = 2.23694
                    
                    self.previousViewController.weightType = "lbs"
                    self.previousViewController.weightTypeCoefficient = 2.20462
                    
                    self.refreshAllLabels()
                }
        
                let speedTypeMpsAction = UIAlertAction (
                    title: NSLocalizedString("native", comment: "Native (m/s - kg)"),
                    style: UIAlertActionStyle.default
                ) {
                    (action) -> Void in
                    self.previousViewController.speedType = "m/s"
                    self.previousViewController.speedTypeCoefficient = 1.0
                    
                    self.previousViewController.weightType = "kg"
                    self.previousViewController.weightTypeCoefficient = 1.0
                    
                    self.refreshAllLabels()
                }
        
                let speedTypeKnotsAction = UIAlertAction (
                    title: NSLocalizedString("aeronautical", comment: "Aeronautical (kn - lbs)"),
                    style: UIAlertActionStyle.default
                ) {
                    (action) -> Void in
                    self.previousViewController.speedType = "kn"
                    self.previousViewController.speedTypeCoefficient = 1.94384
                    
                    self.previousViewController.weightType = "lbs"
                    self.previousViewController.weightTypeCoefficient = 2.20462
                    
                    self.refreshAllLabels()
                }
        
                let cancelButtonAction = UIAlertAction (
                    title: "Cancel",
                    style: UIAlertActionStyle.cancel
                ) {
                    (action) -> Void in
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
        previousViewController.drawRange = Int(sender.value)
        refreshAllLabels()
    }
    
    
    
    func saveSettings() {
        UserDefaults.standard.set(previousViewController.drawRange, forKey: "drawRange")
        UserDefaults.standard.set(previousViewController.speedTypeCoefficient, forKey: "speedTypeCoefficient")
        UserDefaults.standard.set(previousViewController.speedType, forKey: "speedType")
        UserDefaults.standard.set(previousViewController.speedTypeCoefficient, forKey: "speedTypeCoefficient")
        UserDefaults.standard.set(previousViewController.weightType, forKey: "weightType")
        UserDefaults.standard.set(previousViewController.weightTypeCoefficient, forKey: "weightTypeCoefficient")
        UserDefaults.standard.set(previousViewController.weight, forKey: "weight")
    }
    
    func performSegueToReturnBack()  {
        previousViewController.startTimer()
        previousViewController.startSpeedometer()
        saveSettings()
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
            
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
//    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
//                            didRewardUserWith reward: GADAdReward) {
//        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
//        var showAdsDate = UserDefaults.standard.object(forKey: "showAdsDate") as? Date ?? Date()
//        let currentDate = Date()
//        if showAdsDate.seconds(from: currentDate) < 0 {
//            showAdsDate = Date()
//        }
//        let newShowAdsDate = Calendar.current.date(byAdding: .day, value: 1, to: showAdsDate)
//        UserDefaults.standard.set(newShowAdsDate, forKey: "showAdsDate")
//        refreshNoAdsLabel()
//    }
//
//    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd:GADRewardBasedVideoAd) {
//        print("Reward based video ad is received.")
//        loadingAdFinished()
//    }
//
//    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
//        print("Opened reward based video ad.")
//    }
//
//    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
//        print("Reward based video ad started playing.")
//    }
//
//    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
//        print("Reward based video ad is closed.")
//    }
//
//    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
//        print("Reward based video ad will leave application.")
//    }
//
//    func rewardBasedVideoAd(_ rewardBasedVideoAd:  GADRewardBasedVideoAd, didFailToLoadWithError error: Error) {
//        print("error \(String(describing: error))")
//    }
    
    
}

