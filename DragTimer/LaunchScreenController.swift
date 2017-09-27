//
//  LaunchScreenController.swift
//  DragTimer
//
//  Created by Philipp Matthes on 27.09.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit

class LaunchScreenController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    
    override func viewDidLoad() {
        setUpBackground(frame: view.frame)
    }
    
    func setUpBackground(frame: CGRect) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        gradientLayer.colors = [Constants.backgroundColor1.cgColor as CGColor, Constants.backgroundColor2.cgColor as CGColor]
        gradientLayer.locations = [0.0, 1.0]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
}
