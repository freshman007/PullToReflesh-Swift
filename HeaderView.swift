//
//  HeaderView.swift
//  CBReflesh
//
//  Created by 陈超邦 on 16/2/26.
//  Copyright © 2016年 ChenChaobang. All rights reserved.
//

import UIKit

class HeaderView: UIView {

    var waveView:WaveView!
    var ballView:BallView!

    init(frame: CGRect, ballSize: CGFloat, moveUpDuration:CFTimeInterval = 0.7, moveUpDist: CGFloat = 32 * 1.5,ballSpaceBetween: CGFloat = 8,backColor: UIColor = UIColor.clearColor(),color: UIColor = UIColor.groupTableViewBackgroundColor()){
        super.init(frame: frame)
        self.backgroundColor = backColor
        waveView = WaveView.init(frame: frame, color: color)
        self.addSubview(waveView)
        
        ballView = BallView.init(frame: frame, circleSize: ballSize, moveUpDuration: moveUpDuration,moveUpDist: moveUpDist, ballSpaceBetween: ballSpaceBetween, color: color)
        ballView.hidden = true
        self.addSubview(ballView)

        waveView.didEndPull = {
            self.ballView.hidden = false
            self.ballView.startAnimation()
        }
        
    }
    
    func endingAnimation(complition:(()->())? = nil) {
        ballView.endAnimation()
        complition?()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func wave(y: CGFloat) {
        waveView.wave(y)
    }
    
    func didRelease(y: CGFloat) {
        waveView.didRelease(bendDist: y)
    }

}
