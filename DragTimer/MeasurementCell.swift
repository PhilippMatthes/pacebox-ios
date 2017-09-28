//
//  MeasurementCell.swift
//  DragTimer
//
//  Created by Philipp Matthes on 26.09.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class MeasurementCell: UITableViewCell {
    
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.shadowOpacity = 0.18
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.masksToBounds = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
