//
//  BallView.swift
//  CBReflesh
//
//  Created by 陈超邦 on 16/2/29.
//  Copyright © 2016年 ChenChaobang. All rights reserved.
//

import UIKit

private var upDuration: Double!
private var ballSize: CGFloat!
private var ballSpace: CGFloat!

class BallView: UIView {
    
    var didStarUpAnimation: (()->())?
    var circleMoveView: CircleMoveView?
    var endFloatAnimation: (()->())?
    
    init(frame: CGRect,circleSize: CGFloat = 20, moveUpDuration:CFTimeInterval, moveUpDist:CGFloat, ballSpaceBetween:CGFloat = 5, color:UIColor) {
        
        upDuration = moveUpDuration
        ballSize = circleSize
        ballSpace = ballSpaceBetween
        
        super.init(frame:frame)
        
        for var i = 3;i >= 0;i-- {
            circleMoveView = CircleMoveView.init(frame: frame,circleSize: circleSize, moveUpDist: moveUpDist, color: color)
            circleMoveView!.tag = 100 + i
            self.addSubview(circleMoveView!)
            
            self.didStarUpAnimation = {
                for var i = 3;i >= 0;i-- {
                    self.circleMoveView = self.viewWithTag(100 + i) as? CircleMoveView
                    self.circleMoveView!.circleLayer.startAnimationUp(ballTag: i)
                }
            }
            self.endFloatAnimation = {
                for var i = 3;i >= 0;i-- {
                    self.circleMoveView = self.viewWithTag(100 + i) as? CircleMoveView
                    self.circleMoveView!.circleLayer.stopFloatAnimation(ballTag: i)
                }
            }
        }
    }
    
      required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimation() {
       didStarUpAnimation!()
    }
    
    func endAnimation() {
        endFloatAnimation!()
    }
}

class CircleMoveView: UIView {
    
    var circleLayer: CircleLayer!
    
    init(frame: CGRect, circleSize: CGFloat, moveUpDist: CGFloat, color: UIColor) {
        super.init(frame: frame)
        
        circleLayer = CircleLayer(
            size: circleSize,
            moveUpDist: moveUpDist,
            superViewFrame: self.frame,
            color: color
        )
        self.layer.addSublayer(circleLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class CircleLayer :CAShapeLayer {
    
    var timer:NSTimer?
    var moveUpDist: CGFloat!
    var didEndAnimation: (()->())?
    
    var layerTag: Int?
    
    init(size:CGFloat, moveUpDist:CGFloat, superViewFrame:CGRect, color:UIColor) {
        self.moveUpDist = moveUpDist
        let selfFrame = CGRectMake(0, 0, superViewFrame.size.width, superViewFrame.size.height)
        super.init()
        
        let radius:CGFloat = size / 2
        self.frame = selfFrame
        let center = CGPointMake(superViewFrame.size.width / 2, superViewFrame.size.height/2)
        let startAngle = 0 - M_PI_2
        let endAngle = M_PI * 2 - M_PI_2
        let clockwise: Bool = true
        self.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: clockwise).CGPath
        self.fillColor = color.colorWithAlphaComponent(1).CGColor
        self.strokeColor = self.fillColor
        self.lineWidth = 0
        self.strokeEnd = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimationUp(ballTag ballTag: Int) {
        layerTag = ballTag
        let distance_left = (ballSize + ballSpace) * (1.5 - CGFloat(ballTag))
        self.moveUp(distance_up:moveUpDist, distance_left: distance_left)
    }
    
    func endAnimation(complition:(()->())? = nil) {
        didEndAnimation = complition
    }
    
    func moveUp(distance_up distance_up: CGFloat,distance_left: CGFloat) {
        
        self.hidden = false
        let move = CAKeyframeAnimation(keyPath: "position")
        let angle_1 = atan(Double(abs(distance_left)) / Double(distance_up))
        let angle_2 = M_PI -  angle_1 * 2
        let radii: Double = pow((pow(Double(distance_left), 2)) + pow(Double(distance_up), 2), 1 / 2) / (cos(angle_1) * 2)
        let centerPoint: CGPoint = CGPoint(x: 160 - distance_left, y: CGFloat(radii) - distance_up)
        var endAngle: CGFloat = CGFloat(3 * M_PI_2)
        var startAngle: CGFloat = CGFloat(3 / 2 * M_PI - angle_2)
        var bezierPath = UIBezierPath()
        var clockwise:Bool = true
        
        if distance_left > 0 {
            clockwise = false
            startAngle =  CGFloat(3 / 2 * M_PI + angle_2)
            endAngle = CGFloat(3 * M_PI_2)
        }
        
        bezierPath = UIBezierPath.init(arcCenter: centerPoint, radius: CGFloat(radii), startAngle: startAngle , endAngle: endAngle, clockwise: clockwise)
        move.path = bezierPath.CGPath
        move.duration = upDuration
        move.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        move.fillMode = kCAFillModeForwards
        move.removedOnCompletion = false
        move.delegate = self
        self.addAnimation(move, forKey: move.keyPath)
        
    }
    
    func floatUpOrDown() {
        let move = CAKeyframeAnimation(keyPath: "position.y")
        move.values = [0,1,2,3,4,5,4,3,2,1,0,-1,-2,-3,-4,-5,-4,-3,-2,-1,0]
        move.duration = 1
        move.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        move.additive = true
        move.fillMode = kCAFillModeForwards
        move.removedOnCompletion = false
        self.addAnimation(move, forKey: move.keyPath)
    }

    func stopFloatAnimation(ballTag ballTag: Int) {
        timer?.invalidate()
        self.hidden = true
        self.removeAllAnimations()
    }

    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        
        let animation:CAKeyframeAnimation = anim as! CAKeyframeAnimation
        if animation.keyPath == "position" {
            let timeDelay: NSTimeInterval =  Double(layerTag!) * 0.2
            timer = NSTimer.schedule(delay: timeDelay, repeatInterval: 1, handler: { (timer) -> Void in
                self.floatUpOrDown()
            })
        }
    }
}