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
    
    var outerEndPercentage = Double()
    var innerStartPercentage = Double()
    var innerEndPercentage = Double()
    var circleLayer: CAShapeLayer!
    var innerCircleLayer: CAShapeLayer!
    let margin = 30
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        outerEndPercentage = 0
        innerEndPercentage = 0
        innerStartPercentage = 0
        
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
        let translation = CATransform3DMakeTranslation(frame.width/2 - frame.minX + 80, frame.height/2 - frame.minY + 160, 0)
        let rotation = CATransform3DMakeRotation(CGFloat(Double.pi/2), 0, 0, 1.0)
        circleLayer.transform = CATransform3DConcat(rotation, translation)
        
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: -80, y: -160, width: frame.width+80, height: frame.height+80)
        gradient.colors = [Constants.designColor1.cgColor as CGColor,
                           Constants.designColor2.cgColor as CGColor]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.mask = circleLayer
        
        layer.addSublayer(gradient)
        
        let innerCirclePath = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: frame.size.width/2 - 40, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        // Setup the CAShapeLayer with the path, colors, and line width
        innerCircleLayer = CAShapeLayer()
        innerCircleLayer.lineCap = kCALineCapRound
        innerCircleLayer.path = innerCirclePath.cgPath
        innerCircleLayer.fillColor = UIColor.clear.cgColor
        innerCircleLayer.strokeColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor as CGColor
        innerCircleLayer.lineWidth = 5
        
        let innerTranslation = CATransform3DMakeTranslation(frame.width/2 - frame.minX, frame.height/2 - frame.minY, 0)
        let innerRotation = CATransform3DMakeRotation(CGFloat(Double.pi/2), 0, 0, 1.0)
        
        // Don't draw the circle initially
        innerCircleLayer.strokeEnd = 1.0
        innerCircleLayer.transform = CATransform3DConcat(innerRotation, innerTranslation)

        layer.addSublayer(innerCircleLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animateCircle(duration: TimeInterval, currentSpeed: Double, maxSpeed: Double, highSpeed: Double, lowSpeed: Double, speedTypeCoefficient: Double) {
        
        let convertedCurrentSpeed = currentSpeed * speedTypeCoefficient
        let convertedMaxSpeed = maxSpeed * speedTypeCoefficient
        let outerStrokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        let innerStrokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        let innerStrokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        
        let speedometerMaxValue = max(max(convertedCurrentSpeed, convertedMaxSpeed),highSpeed)
        
        outerStrokeEndAnimation.duration = duration
        innerStrokeEndAnimation.duration = duration
        innerStrokeStartAnimation.duration = duration
        
        outerStrokeEndAnimation.fromValue = outerEndPercentage
        outerEndPercentage = convertedCurrentSpeed/speedometerMaxValue
        outerStrokeEndAnimation.toValue = outerEndPercentage
        
        innerStrokeEndAnimation.fromValue = innerEndPercentage
        innerEndPercentage = highSpeed/speedometerMaxValue
        innerStrokeEndAnimation.toValue = innerEndPercentage
        
        innerStrokeStartAnimation.fromValue = innerStartPercentage
        innerStartPercentage = lowSpeed/speedometerMaxValue
        innerStrokeStartAnimation.toValue = innerStartPercentage
        
        outerStrokeEndAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        innerStrokeEndAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        innerStrokeStartAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        circleLayer.strokeEnd = CGFloat(outerEndPercentage)
        innerCircleLayer.strokeEnd = CGFloat(innerEndPercentage)
        innerCircleLayer.strokeStart = CGFloat(innerStartPercentage)

        circleLayer.add(outerStrokeEndAnimation, forKey: "outerStrokeEndAnimation")
        innerCircleLayer.add(innerStrokeEndAnimation, forKey: "innerStrokeEndAnimation")
        innerCircleLayer.add(innerStrokeStartAnimation, forKey: "innerStrokeStartAnimation")
    }
    

}
