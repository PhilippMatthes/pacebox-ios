//
//  SettingsController.swift
//  DragTimer
//
//  Created by Philipp Matthes on 18.09.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class SettingsController: UIViewController, GADRewardBasedVideoAdDelegate {
    
    @IBOutlet weak var speedTypeButtonBackground: UIView!
    
    @IBOutlet weak var speedTypeButton: UIButton!
    @IBOutlet weak var speedTypeBackground: UIView!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var logSizeBackground: UIView!
    @IBOutlet weak var logSizeSlider: UISlider!
    @IBOutlet weak var logSizeSliderBackground: UIView!
    @IBOutlet weak var logSizeSliderLabel: UILabel!
    @IBOutlet weak var adBackground: UIView!
    @IBOutlet weak var adButtonBackground: UIView!
    @IBOutlet weak var adFreeTimeLabel: UILabel!
    @IBOutlet weak var loadAdLabel: UILabel!
    
    var rewardBasedVideo: GADRewardBasedVideoAd?
    
    var previousViewController = ViewController()
    
    let gradientLayer = CAGradientLayer()
    
    var speedType = String()
    var speedTypeCoefficient = Double()
    var weightType = String()
    var weightTypeCoefficient = Double()
    var drawRange = Int()
    var adWasReceived = false
    
    weak var adTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInterfaceDesign()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        adTimer?.invalidate()
    }
    
    func startTimer() {
        adTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(advanceAdTimer(timer:)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc func advanceAdTimer(timer: Timer) {
        refreshNoAdsLabel()
    }
    
    func receiveAd() {
        rewardBasedVideo = GADRewardBasedVideoAd.sharedInstance()
        rewardBasedVideo?.delegate = self
        let request = GADRequest()
//        request.testDevices = [kGADSimulatorID]
        rewardBasedVideo?.load(request,
                               withAdUnitID: "ca-app-pub-5941274384378366/6654609430")
    }
    
    func presentAd() {
        if rewardBasedVideo?.isReady == true {
            rewardBasedVideo?.present(fromRootViewController: self)
        }
    }
    
    func setUpInterfaceDesign() {
        
        let backgrounds = [speedTypeBackground,
                           logSizeBackground,
                           adBackground]
        
        let buttonBackgrounds = [adButtonBackground,
                                 logSizeSliderBackground,
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
            background?.dropShadow(color: UIColor.black,
                                   opacity: 1.0,
                                   offSet: CGSize(),
                                   radius: 3,
                                   scale: true)
            background?.layer.backgroundColor = Constants.interfaceColor.cgColor
        }
        
        self.view.addSubview(navigationBar)
        let navigationItem = UINavigationItem(title: "Settings")
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector (self.closeButtonPressed (_:)))
        doneItem.tintColor = Constants.designColor1
        navigationItem.rightBarButtonItem = doneItem
        navigationBar.setItems([navigationItem], animated: false)
        
        logSizeSlider.tintColor = Constants.designColor1
        
        setUpBackground(frame: self.view.bounds)
        
        let adClickRecognizer = UITapGestureRecognizer(target: self, action:  #selector (self.adButtonClicked(sender:)))
        adButtonBackground.addGestureRecognizer(adClickRecognizer)
        
        refreshAllLabels()
    }
    
    @objc func adButtonClicked(sender:UITapGestureRecognizer) {
        animateButtonPressOn(background: adButtonBackground)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.animateButtonReleaseOff(background: self.adButtonBackground)
        })
        if !adWasReceived {
            receiveAd()
            showAdLoading()
        }
        else {
            presentAd()
            UIView.animate(withDuration: 0.3, animations: {
                self.loadAdLabel.alpha = 0.0
            })
            loadAdLabel.text = "Load Ad"
            UIView.animate(withDuration: 0.3, animations: {
                self.loadAdLabel.alpha = 1.0
            })
            adWasReceived = false
        }
    }
    
    func showAdLoading() {
        UIView.animate(withDuration: 0.3, animations: {
            self.loadAdLabel.alpha = 0.0
        })
        let alert = UIAlertController(title: nil, message: "Loading ad...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating()
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    func loadingAdFinished() {
        dismiss(animated: false, completion: nil)
        self.loadAdLabel.text = "Play Ad"
        UIView.animate(withDuration: 0.3, animations: {
            self.loadAdLabel.alpha = 1.0
        })
        adWasReceived = true
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
        speedTypeButton.setTitle(speedType + " - " + weightType, for: .normal)
        logSizeSliderLabel.text = String(drawRange)
        logSizeSlider.value = Float(drawRange)
        refreshNoAdsLabel()
    }

    func refreshNoAdsLabel() {
        let showAdsDate = UserDefaults.standard.object(forKey: "showAdsDate") as? Date ?? Date()
        let currentDate = Date()
        let days = showAdsDate.days(from: currentDate)
        let hours = showAdsDate.hours(from: currentDate) % 24
        let minutes = showAdsDate.minutes(from: currentDate) % 60
        let seconds = showAdsDate.seconds(from: currentDate) % 60
        let time = showAdsDate.seconds(from: currentDate)
        if time < 0 {
            adFreeTimeLabel.text = "0d, 0h, 0min, 0s"
        }
        else {
            adFreeTimeLabel.text = String(days)+"d, "+String(hours)+"h, "+String(minutes)+"min, "+String(seconds)+"s"
        }
    }
    
    @IBAction func speedTypeButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(
                    title: "Units selection",
                    message: nil,
                    preferredStyle: UIAlertControllerStyle.actionSheet
                )
        
                let speedTypeKphAction = UIAlertAction (
                    title: "Metric (km/h - kg)",
                    style: UIAlertActionStyle.default
                ) {
                    (action) -> Void in
                    self.speedType = "km/h"
                    self.speedTypeCoefficient = 3.6
                    
                    self.weightType = "kg"
                    self.weightTypeCoefficient = 1.0
                    
                    self.refreshAllLabels()
                }
        
                let speedTypeMphAction = UIAlertAction (
                    title: "Imperialistic (mph - lbs)",
                    style: UIAlertActionStyle.default
                ) {
                    (action) -> Void in
                    self.speedType = "mph"
                    self.speedTypeCoefficient = 2.23694
                    
                    self.weightType = "lbs"
                    self.weightTypeCoefficient = 2.20462
                    
                    self.refreshAllLabels()
                }
        
                let speedTypeMpsAction = UIAlertAction (
                    title: "Native (m/s - kg)",
                    style: UIAlertActionStyle.default
                ) {
                    (action) -> Void in
                    self.speedType = "m/s"
                    self.speedTypeCoefficient = 1.0
                    
                    self.weightType = "kg"
                    self.weightTypeCoefficient = 1.0
                    
                    self.refreshAllLabels()
                }
        
                let speedTypeKnotsAction = UIAlertAction (
                    title: "Aeronautical (kn - lbs)",
                    style: UIAlertActionStyle.default
                ) {
                    (action) -> Void in
                    self.speedType = "kn"
                    self.speedTypeCoefficient = 1.94384
                    
                    self.weightType = "lbs"
                    self.weightTypeCoefficient = 2.20462
                    
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
    
    
    
    func saveSettings() {
        UserDefaults.standard.set(drawRange, forKey: "drawRange")
        UserDefaults.standard.set(speedTypeCoefficient, forKey: "speedTypeCoefficient")
        UserDefaults.standard.set(speedType, forKey: "speedType")
        UserDefaults.standard.set(speedType, forKey: "speedType")
        UserDefaults.standard.set(speedTypeCoefficient, forKey: "speedTypeCoefficient")
        UserDefaults.standard.set(weightType, forKey: "weightType")
        UserDefaults.standard.set(weightTypeCoefficient, forKey: "weightTypeCoefficient")
        UserDefaults.standard.set(previousViewController.weight, forKey: "weight")
    }
    
    func performSegueToReturnBack()  {
        previousViewController.startTimer()
        previousViewController.startSpeedometer()
        previousViewController.drawRange = drawRange
        previousViewController.speedTypeLabel.text = speedType
        previousViewController.speedTypeCoefficient = speedTypeCoefficient
        previousViewController.speedType = speedType
        previousViewController.weightType = weightType
        previousViewController.weightTypeCoefficient = weightTypeCoefficient
        previousViewController.weightField.text = String(Int(Double(round(100 * previousViewController.weight * weightTypeCoefficient)/100))) + " " + weightType
        saveSettings()
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
            
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        var showAdsDate = UserDefaults.standard.object(forKey: "showAdsDate") as? Date ?? Date()
        let currentDate = Date()
        if showAdsDate.seconds(from: currentDate) < 0 {
            showAdsDate = Date()
        }
        let newShowAdsDate = Calendar.current.date(byAdding: .day, value: 1, to: showAdsDate)
        UserDefaults.standard.set(newShowAdsDate, forKey: "showAdsDate")
        refreshNoAdsLabel()
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd:GADRewardBasedVideoAd) {
        print("Reward based video ad is received.")
        loadingAdFinished()
    }
    
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Opened reward based video ad.")
    }
    
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad started playing.")
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad is closed.")
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad will leave application.")
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd:  GADRewardBasedVideoAd, didFailToLoadWithError error: Error) {
        print("error \(String(describing: error))")
    }
    
    
}

