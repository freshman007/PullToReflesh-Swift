//
//  WaveView.swift
//  CBReflesh
//
//  Created by 陈超邦 on 16/2/26.
//  Copyright © 2016年 ChenChaobang. All rights reserved.
//

import UIKit

class WaveView: UIView {
    
    var waveLayer:CAShapeLayer!
    var bounceDuration:CFTimeInterval!
    var didEndPull: (()->())?

    init(frame:CGRect,bounceDuration:CFTimeInterval = 0.2,color:UIColor) {
        super.init(frame:frame)
        self.bounceDuration = bounceDuration

        waveLayer = CAShapeLayer(layer: self.layer)
        waveLayer.lineWidth = 0
        waveLayer.strokeColor = color.CGColor
        waveLayer.fillColor = color.CGColor
        self.layer.addSublayer(waveLayer)
    }
    
    func wave(y:CGFloat) {
        self.waveLayer.path = self.wavePath(bendDist: y)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func boundAnimation(bendDist bendDist: CGFloat) {
        let bounce = CAKeyframeAnimation(keyPath: "path")
        bounce.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        let values = [
            self.wavePath(bendDist: bendDist),
            self.wavePath(bendDist: bendDist * 0.8),
            self.wavePath(bendDist: bendDist * 0.6),
            self.wavePath(bendDist: bendDist * 0.4),
            self.wavePath(bendDist: bendDist * 0.2),
            self.wavePath(bendDist: 0)
        ]
        bounce.values = values
        bounce.duration = bounceDuration
        bounce.removedOnCompletion = false
        bounce.fillMode = kCAFillModeForwards
        bounce.delegate = self
        self.waveLayer.addAnimation(bounce, forKey: "return")
    }
    
    func wavePath(bendDist bendDist:CGFloat) -> CGPathRef {
        let width = self.frame.width
        let height = self.frame.height
        
        let bottomLeftPoint = CGPointMake(0, height)
        let topMidPoint = CGPointMake(width / 2,  -bendDist)
        let bottomRightPoint = CGPointMake(width, height)
        
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(bottomLeftPoint)
        bezierPath.addQuadCurveToPoint(bottomRightPoint, controlPoint: topMidPoint)
        bezierPath.addLineToPoint(bottomLeftPoint)
        return bezierPath.CGPath
    }
    
    func didRelease(bendDist bendDist: CGFloat) {
        self.boundAnimation(bendDist: bendDist)
        didEndPull?()
    }
    
    func endAnimation() {
        self.waveLayer.removeAllAnimations()
    }

 }
