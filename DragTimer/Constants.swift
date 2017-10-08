//
//  Constants.swift
//  DragTimer
//
//  Created by Philipp Matthes on 27.09.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let cornerRadius = CGFloat(5.0)
    
    
    static let backgroundColor1 = UIColor(rgb: 0x16222A, alpha: 1.0)
    static let backgroundColor2 = UIColor(rgb: 0x3A6073, alpha: 1.0)
    static let backgroundColorDark1 = UIColor(rgb: 0x000000, alpha: 1.0)
    static let backgroundColorDark2 = UIColor(rgb: 0x000000, alpha: 1.0)
    static let designColor1 = UIColor(rgb: 0xee0979, alpha: 1.0)
    static let designColor2 = UIColor(rgb: 0xff6a00, alpha: 1.0)
    static let graphColor = UIColor(rgb: 0xffffff, alpha: 0.25)
    static let interfaceColor = UIColor(rgb: 0xffffff, alpha: 0.75)
    
    static let font = UIFont(name: "Futura", size: 22.0)
    
}

extension UIColor {
    convenience init(rgb: Int, alpha: CGFloat) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF)/255,
            green: CGFloat((rgb >> 8) & 0xFF)/255,
            blue: CGFloat(rgb & 0xFF)/255,
            alpha: alpha
        )
    }
}
