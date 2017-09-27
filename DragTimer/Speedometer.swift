//
//  Speedometer.swift
//  DragTimer
//
//  Created by Philipp Matthes on 27.09.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import UIKit
import GLKit

class Speedometer: UIView {
    
    var percentage = Double()
    var circleLayer: CAShapeLayer!
    let margin = 30
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        percentage = 0
        
        // Use UIBezierPath as an easy way to create the CGPath for the layer.
        // The path should be the entire circle.
        let startAngle = CGFloat( 2 * Double.pi / 360 * 30 )
        let endAngle = CGFloat( 2 * Double.pi / 360 * 330 )
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: frame.size.width/2 - 20, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        // Setup the CAShapeLayer with the path, colors, and line width
        circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor as CGColor
        circleLayer.lineWidth = 20
        circleLayer.lineDashPattern = [2, 5]
        
        
        // Don't draw the circle initially
        circleLayer.strokeEnd = 0.0
        let translation = CATransform3DMakeTranslation(frame.width/2 - frame.minX + 40, frame.height/2 - frame.minY + 80, 0)
        let rotation = CATransform3DMakeRotation(CGFloat(Double.pi/2), 0, 0, 1.0)
        circleLayer.transform = CATransform3DConcat(rotation, translation)
        
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: -40, y: -80, width: frame.width+40, height: frame.height+40)
        gradient.colors = [Constants.designColor1.cgColor as CGColor,
                           Constants.designColor2.cgColor as CGColor]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.mask = circleLayer
        
        layer.addSublayer(gradient)

        
        
        // Add the circleLayer to the view's layer's sublayers
//        layer.addSublayer(circleLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animateCircle(duration: TimeInterval, newPercentage: Double) {
        // We want to animate the strokeEnd property of the circleLayer
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        // Set the animation duration appropriately
        animation.duration = duration
        
        // Animate from 0 (no circle) to 1 (full circle)
        animation.fromValue = percentage
        animation.toValue = newPercentage
        percentage = newPercentage
        
        // Do a linear animation (i.e. the speed of the animation stays the same)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        // Set the circleLayer's strokeEnd property to 1.0 now so that it's the
        // right value when the animation ends.
        circleLayer.strokeEnd = CGFloat(newPercentage)
        
        // Do the actual animation
        circleLayer.add(animation, forKey: "animateCircle")
    }
    

}
