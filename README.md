#pullToReflesh-Swift
## 前言：
>一直对于**贝塞尔曲线**和**动画**的知识缺乏了解，所以觉得应该写一点东西来真正的掌握这两个知识点，刚好在**Dribbble**上看到这样的一个设计，就想着做出来，应该有所帮助。

设计效果如下：

<center>![](https://d13yacurqjgara.cloudfront.net/users/141880/screenshots/2542648/dailyui-094.gif "Demo GIF Animation")</center>

**Dribbble**网址：[Daily-UI-094-News](https://dribbble.com/shots/2542648-Daily-UI-094-News)

## 思路分析：
以下将针对设计过程中的知识点进行详细的记录。
### 使用贝塞尔曲线画波纹
![](http://r6.loli.io/uIvERv.png)

这样的曲线相对简单，我们这里直接使用系统提供的**一次贝塞尔曲线**方法:

``` 
public func addQuadCurveToPoint(endPoint: CGPoint, controlPoint: CGPoint)
```
但是我们还需要根据scrollView的contentOffSet来动态改变该曲线的弧线曲折度，所以这里我们将改变曲折度写成一个方法：

``` swift  
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

```

这样我们就可以通过只传入bendDist来改变曲折度。

### 波纹曲线回滚动画
根据上面的动图，我们可以看到开始刷新操作时，曲折度逐渐减小，这里我们需要一个动画来实现这个功能：

``` swift  
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
```

至此波纹曲线的部分就基本完成。

### scrollView回滚动画
![](http://ww2.sinaimg.cn/large/0060lm7Tgw1f1kouoq6suj31kw0dit91.jpg)
#### 问题
在进行波纹曲线回滚动画的时候，我们的scrollView也有适当的上移，这样的上移动画，如果直接使用`setContentOffset`  来进行视图的移动，选择`animation: true`的情况下，每一次移动，都会使得scrollView从顶部重新移动到目标位置，造成视图一直闪的情况。
#### 解决方案
为了避免这样的情况，我们可以依然选择`setContentOffset`  来进行scrollView的视图移动，但是我们设置`animation: false`来关闭系统提供的动画，选择自己来实现动画的效果。
1. 首先，我们设置一个定时器：

``` swift
NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "scollBackAnimation:", userInfo:stepNum, repeats: true)
```

这个定时器的时间步进我们设置为0.01s，是因为`NSTimer`准确度并不高。然后我们给这个定时器附加一个`stepNum`的属性，这个属性指的是每一次执行`setContentOffset`向上移动的距离，这个属性的值，我们这样子计算：
![](http://7xrn7f.com1.z0.glb.clouddn.com/16-3-11/40473149.jpg)
然后，我们每隔0.01秒，刷新一次`contentOffset`,形成一种视图向上持续移动的视觉效果，代码如下：

``` swift
    func scollBackAnimation(timer: NSTimer) {
        let stepNum = timer.userInfo! as! CGFloat
        scrollViewContentOffSetY = scrollViewContentOffSetY! + stepNum
        if scrollViewContentOffSetY >= finalScrollViewContentOffSetY {
            timer.invalidate()
        }
        scrollView?.setContentOffset(CGPoint(x: 0, y: scrollViewContentOffSetY!), animated: false)
    }
```
接下来，我们来做小球的部分。
### 使用贝塞尔曲线画小球
这里，我们使用**贝塞尔曲线画任意弧度**的一个方法：

``` swift
public convenience init(arcCenter center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool)
```
这个工厂方法用于画弧，参数说明如下：
**center**：弧线中心点的坐标，**radius**：弧线所在圆的半径 **startAngle**：弧线开始的角度值 **endAngle**：弧线结束的角度值 **clockwise**：是否顺时针画弧线。
### 使用贝塞尔曲线画出小球的运动轨迹
画出小球是比较容易的部分，但是想要画出小球的运行轨迹就稍微有点复杂。
以下我们较为详细的来说明一下：
>这一部分，如何去做更重要，牵扯到很多小细节，代码就不贴了，请看项目文件

#### 草稿思维图
![](http://i4.tietuku.cn/04fe913127f6904e.jpg)
![](http://7xrn7f.com1.z0.glb.clouddn.com/16-3-11/96817311.jpg)
##### 求x,y
![](http://i4.tietuku.cn/8ccd608263376e9e.jpg)
![](http://7xrn7f.com1.z0.glb.clouddn.com/16-3-11/94836323.jpg)
### 小球的浮动动画
小球的浮动只是简单的上下位置的变换，值得注意的是每颗小球开始动画的时间点存在差值，这个差值使得小球有了错位浮动的效果，下面是代码：

``` swift
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
``` 

``` swift
            let timeDelay: NSTimeInterval =  Double(layerTag!) * 0.2
            timer = NSTimer.schedule(delay: timeDelay, repeatInterval: 1, handler: { (timer) -> Void in
                self.floatUpOrDown()
            })
``` 
## 总结：
>这一次的demo比较简单，还是花了两天半的时间，如果说有什么感想，就还是需要继续努力。


## Usage

### Wrap your scrollView

``` 
let tableViewWrapper = PullToRefleshView(scrollView: yourTableView)
bodyView.addSubview(tableViewWrapper)
```
The color of the wrapper will be same as your scrollView's background color.


### Handler

``` 
tableViewWrapper.didPullToRefresh = {
   //you can do anythings you want after beginning to reflesh
}
```
You can end the reflesh simplily 

```
 tableViewWrapper.endReflesh()
```


