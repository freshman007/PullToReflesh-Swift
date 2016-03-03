//
//  PullToRefleshView.swift
//  CBReflesh
//
//  Created by 陈超邦 on 16/2/26.
//  Copyright © 2016年 ChenChaobang. All rights reserved.
//

import UIKit


class PullToRefleshView: UIView {

    var pullDist: CGFloat?
    var bendDist: CGFloat?
    var stopDist: CGFloat?
    var upDuration: CFTimeInterval?

    var headerView: HeaderView!
    var scrollView: UIScrollView?
    
    var scrollViewContentOffSetY: CGFloat?
    var finalScrollViewContentOffSetY: CGFloat?
    
    internal var didPullToRefresh: (()->())?
    
    init(scrollView: UIScrollView,ballSize: CGFloat = 15,ballSpaceBetween: CGFloat = 10,pullDistance: CGFloat = 80,moveUpDuration: CFTimeInterval = 0.5,bendDistance: CGFloat = 50,stopDistance: CGFloat = 70,backgroundColor: UIColor = UIColor.clearColor(), didPullToRefresh: (()->())? = nil){
        
        if scrollView.frame == CGRectZero {
            assert(false, "ScrollView got the wrong frame")
        }
        super.init(frame: scrollView.frame)
        self.pullDist = pullDistance
        self.bendDist = bendDistance * 2
        self.stopDist = stopDistance
        self.upDuration = moveUpDuration
        self.didPullToRefresh = didPullToRefresh

        headerView = HeaderView.init(frame: CGRectMake(0, 0, scrollView.frame.size.width, 0),ballSize: ballSize,moveUpDuration: upDuration!,ballSpaceBetween: ballSpaceBetween,moveUpDist: stopDist! / 2,backColor: backgroundColor,color: UIColor.groupTableViewBackgroundColor())
        (scrollView as! UITableView).tableHeaderView = headerView
        
        self.scrollView = scrollView
        scrollView.backgroundColor = UIColor.init(red: 192/255, green: 194/255, blue: 196/255, alpha: 1)
        self.addSubview(scrollView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .Initial, context: &KVOContext)

    }
    
    deinit {
        scrollView?.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &KVOContext)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func scrollViewDidScroll() {
        if scrollView?.contentOffset.y < 0 {
            let y = scrollView!.contentOffset.y * -1
            if y < pullDist {
                headerView.frame.height = y
                let bendDistance: CGFloat = bendDist! / 4 + (bendDist! - bendDist! / 4) * y / pullDist!
                headerView.wave(bendDistance)
            }
            else if y > pullDist! {
                scrollView?.scrollEnabled = false
                headerView.frame.height = y
                scrollViewContentOffSetY = -pullDist!
                finalScrollViewContentOffSetY = -stopDist!
                scrollView?.setContentOffset(CGPoint(x: 0, y: scrollViewContentOffSetY!), animated: false)
                startScrollBackAnimation(scrollDurationInSeconds: CGFloat(upDuration!) / 1.75, distance: pullDist! - stopDist!)
                headerView.wave(bendDist!)
                headerView.didRelease(bendDist!)
                self.didPullToRefresh?()
            }
        }
    }
    
    internal func endReflesh() {
        headerView.endingAnimation {
            self.scrollView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            self.scrollView?.scrollEnabled = true
            NSTimer.schedule(delay: 0.5, handler: { (timer) -> Void in
                self.headerView.waveView.endAnimation()
            })
        }
    }
    
    private func startScrollBackAnimation(scrollDurationInSeconds scrollDurationInSeconds: CGFloat, distance: CGFloat) {
        let stepNum: CGFloat = distance / (scrollDurationInSeconds * 100)
         NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "scollBackAnimation:", userInfo:stepNum, repeats: true)
    }
    
    func scollBackAnimation(timer: NSTimer) {
        let stepNum = timer.userInfo! as! CGFloat
        scrollViewContentOffSetY = scrollViewContentOffSetY! + stepNum
        if scrollViewContentOffSetY >= finalScrollViewContentOffSetY {
            timer.invalidate()
        }
        scrollView?.setContentOffset(CGPoint(x: 0, y: scrollViewContentOffSetY!), animated: false)
    }

    // MARK: ScrollView KVO
    private var KVOContext = "PullToRefreshKVOContext"
    private let contentOffsetKeyPath = "contentOffset"
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<()>) {
        if (context == &KVOContext && keyPath == contentOffsetKeyPath && object as? UIScrollView == scrollView) {
            scrollViewDidScroll()
        }
        else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
}
