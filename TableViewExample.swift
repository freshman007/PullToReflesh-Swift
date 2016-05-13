//
//  TableViewExample.swift
//  CBReflesh
//
//  Created by 陈超邦 on 16/2/26.
//  Copyright © 2016年 ChenChaobang. All rights reserved.
//

import UIKit

class TableViewExample: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bodyView = UIView()
        bodyView.frame = self.view.frame
        bodyView.frame.y += 20 + 60
        self.view.addSubview(bodyView)
        
        let headerView_up = UIView()
        headerView_up.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 20)
        headerView_up.backgroundColor = UIColor.init(red: 55/255, green: 110/255, blue: 201/255, alpha: 1)
        self.view.addSubview(headerView_up)
        
        let headerView_down = UIView()
        headerView_down.frame = CGRect(x: 0, y: 20, width: view.frame.width, height: 60)
        headerView_down.backgroundColor = UIColor.init(red: 66/255, green: 132/255, blue: 243/255, alpha: 1)
        self.view.addSubview(headerView_down)
        
        let tableView = SampleTableView(frame: self.view.frame, style: UITableViewStyle.Plain)
        let tableViewWrapper = PullToRefleshView(scrollView: tableView)
        bodyView.addSubview(tableViewWrapper)

        tableViewWrapper.didPullToRefresh = {
            NSTimer.schedule(delay: 2) { timer in
                tableViewWrapper.endReflesh()
            }
        }

    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

class SampleTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.delegate = self
        self.dataSource = self
        self.registerClass(SampleCell.self, forCellReuseIdentifier: "SampleCell")
        self.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        return 30
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SampleCell", forIndexPath: indexPath) as! SampleCell
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 92
    }
}

class SampleCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.groupTableViewBackgroundColor()
        self.selectionStyle = .None
        let iconMock = UIView()
        iconMock.backgroundColor = UIColor.whiteColor()
        iconMock.frame = CGRect(x: 10, y: 10, width: UIScreen.mainScreen().bounds.size.width - 20, height: 75)
        self.addSubview(iconMock)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

