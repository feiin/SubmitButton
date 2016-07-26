//
//  SubmitButton.swift
//  SubmitButton
//
//  Created by yangyin on 16/7/22.
//  Copyright © 2016年 swiftmi. All rights reserved.
//

import UIKit

enum SubmitButtonState: Int {
    case Original = 0
    case Loading = 1
    case Finished = 2
    case Error = 3
}

 
@IBDesignable
class SubmitButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
   @IBInspectable var checkLineWidth: CGFloat = 8
    var originalColor: CGColorRef = UIColor(red:0, green:206/255, blue:148/255, alpha:1).CGColor
    var originalBorderColor: CGColorRef = UIColor(red:0, green:206/255, blue:148/255, alpha:1).CGColor
    @IBInspectable var progressBorderWidth: CGFloat = 5.0
    private var originTitleColor:UIColor!
    
    
    var stateChanged:((toState: SubmitButtonState)->Void)? = nil
    
    private lazy var loadingCornerRadius:CGFloat = {
        return self.layer.bounds.height / 2
    }()
    
    private lazy var originHeight:CGFloat = {
        return self.layer.bounds.height
    }()
    
    private lazy var loadingBounds:CGRect = {
        
        var bounds: CGRect = self.layer.bounds
        bounds.size.width = bounds.size.height
        return bounds
    }()
    
    private lazy var originBounds:CGRect = {
        
        return self.layer.bounds
    }()
    
    private lazy var originCornerRadius:CGFloat = {
        
        return self.layer.cornerRadius
    }()
    
    
    private func circlePath() -> UIBezierPath {
        let radius = originHeight / 2
        let arcCenter = CGPoint(x: radius, y: radius)
        let startAngle = CGFloat(-M_PI_2)
        let endAngle = startAngle + CGFloat(M_PI*2)
        let path = UIBezierPath(arcCenter: arcCenter, radius: radius - progressBorderWidth/2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        return path
    }
    
    private func successPath() -> UIBezierPath {
        let rect = self.progressLayer.frame;
        let path = UIBezierPath()
        let point1 = CGPointMake(rect.origin.x + rect.size.width*2 / 10, rect.origin.y + rect.size.height*2 / 3)
        let point2 = CGPointMake(rect.origin.x + rect.size.width / 3, rect.origin.y + rect.size.height*8 / 10)
        
        let point3 = CGPointMake(rect.origin.x + rect.size.width*8 / 10, rect.origin.y + rect.size.height*3 / 10)
        path.moveToPoint(point1)
        path.addLineToPoint(point2)
        path.addLineToPoint(point3)
        return path
        
    }
    
    private lazy var progressBarLayer:CALayer = {
        let layer = CALayer()
        let x = (self.layer.bounds.width - self.layer.bounds.height) / 2
        layer.frame = CGRectMake(0, 0, self.layer.bounds.width, self.layer.bounds.height)
 
        layer.masksToBounds = true
        layer.cornerRadius = 0
        layer.backgroundColor = self.originalColor
        layer.borderWidth  = self.progressBorderWidth
        layer.borderColor =  self.originalColor

        return layer
     }()
    
    
    
    private lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        let x = (self.layer.bounds.width - self.layer.bounds.height) / 2
        
        layer.frame = CGRectMake(x, 0, self.layer.bounds.height, self.layer.bounds.height)
        layer.bounds  = self.loadingBounds
        layer.path = self.circlePath().CGPath
        layer.strokeEnd = 0
        layer.strokeStart = 0
        layer.strokeColor = self.originalBorderColor
        layer.fillColor = UIColor.clearColor().CGColor
        layer.masksToBounds = true
        layer.cornerRadius = self.loadingCornerRadius
        layer.backgroundColor = UIColor.clearColor().CGColor
        layer.lineWidth  = self.progressBorderWidth
        layer.borderColor = UIColor.clearColor().CGColor
        
        return layer
        
    }()
    
    private func resetProgress ()
    {
       self.progressLayer.removeAllAnimations()
       self.progress = 0;
       self.lastProgress = 0;

    }
    
    private func resetProgressBar ()
    {
        self.progressBarLayer.removeAllAnimations()
        
    }
    
    private func resetSuccessLayer ()
    {
        self.successLayer.removeAllAnimations()
        self.successLayer.removeFromSuperlayer()
        
    }
    
    private lazy var successLayer: CAShapeLayer = {
        
        let layer = CAShapeLayer()
        layer.path = self.successPath().CGPath
        layer.fillColor = UIColor.clearColor().CGColor
        layer.strokeColor = UIColor.whiteColor().CGColor
        layer.lineWidth = self.checkLineWidth
        layer.lineCap = kCALineCapRound
        layer.lineJoin = kCALineJoinRound
        return layer
    }()
    
    

    private var lastProgress: CGFloat = 0
    
    var progress: CGFloat = 0.0 {
        
        didSet {
            
            
            if progress < 0.0 {
                progress = 0.0
             } else if progress >= 0.99 {
                progress = 1.0
            }
            
            if progress > 0 {
                LoadingAnimation()

            }
//            progressLayer.strokeEnd = progress
        }
    }
    

    func changeState(toState: SubmitButtonState) -> SubmitButton {
        
        self.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)

        switch toState {
        case .Original:
            self.resetProgress()
            self.resetProgressBar()
            self.resetSuccessLayer()
            self.setTitleColor(self.originTitleColor, forState: UIControlState.Normal)
            
            if let stateChanged = self.stateChanged {
                stateChanged(toState: .Original)
            }
        case .Loading:
            self.resetSuccessLayer()
            startLoadingAnimation()
        case .Finished:
            self.layer.addSublayer(successLayer)
            successAnimation()
            self.checkAnimation()
        case .Error:
            break
        }
        return self
    }
    
    private func startLoadingAnimation() {

        let group = CAAnimationGroup()
        group.duration = 0.5
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        group.beginTime = CACurrentMediaTime() + 0.1
        group.fillMode = kCAFillModeForwards
        group.removedOnCompletion = false
        group.delegate = self
        self.layer.backgroundColor = UIColor.clearColor().CGColor
        
        group.setValue("startLoading", forKey: "animationName")
        group.setValue(self.progressBarLayer, forKey: "layer")
        
        // frame
        let sizeAnimation = CABasicAnimation(keyPath: "frame")
        let x = (self.layer.bounds.width - self.layer.bounds.height) / 2
        let toFrame = CGRectMake(x, 0, self.layer.bounds.height, self.layer.bounds.height)

        sizeAnimation.toValue = NSValue(CGRect: toFrame)
        
        // bounds
        let boundsAnimation = CABasicAnimation(keyPath: "bounds")
        boundsAnimation.toValue = NSValue(CGRect: self.loadingBounds)
        
        
        // cornerRadius
        let cornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        cornerRadiusAnimation.toValue = self.loadingCornerRadius
        
        // backgroundColor
        let backgroundColorAnimation = CABasicAnimation(keyPath: "backgroundColor")
        backgroundColorAnimation.toValue = UIColor.clearColor().CGColor
        
        // borderColor
        let borderColorAnimation = CABasicAnimation(keyPath: "borderColor")
         borderColorAnimation.toValue = UIColor.grayColor().CGColor
        
        group.animations = [sizeAnimation, boundsAnimation , cornerRadiusAnimation, backgroundColorAnimation, borderColorAnimation]
        
        self.progressBarLayer.addAnimation(group, forKey: "anim")
        
    }
    
    private func successAnimation() {
        
        let group = CAAnimationGroup()
        group.duration = 0.5
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        group.beginTime = CACurrentMediaTime() + 0.1
        group.fillMode = kCAFillModeForwards
        group.removedOnCompletion = false
        group.delegate = self
        
        group.setValue("success", forKey: "animationName")
        group.setValue(self.progressBarLayer, forKey: "layer")
        
        // frame
        let sizeAnimation = CABasicAnimation(keyPath: "frame")
        let toFrame = CGRectMake(0, 0, self.layer.bounds.width, self.layer.bounds.height)
        
        sizeAnimation.toValue = NSValue(CGRect: toFrame)
        
        // bounds
        let boundsAnimation = CABasicAnimation(keyPath: "bounds")
        boundsAnimation.toValue = NSValue(CGRect: self.originBounds)
        
        
        // cornerRadius
        let cornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        cornerRadiusAnimation.toValue = self.originCornerRadius
        
        // backgroundColor
        let backgroundColorAnimation = CABasicAnimation(keyPath: "backgroundColor")
        backgroundColorAnimation.toValue = self.originalColor
        // borderColor
        let borderColorAnimation = CABasicAnimation(keyPath: "borderColor")
        borderColorAnimation.fromValue = self.originalColor
        borderColorAnimation.toValue = self.originalColor
    
        group.animations = [sizeAnimation, boundsAnimation , cornerRadiusAnimation, backgroundColorAnimation, borderColorAnimation]
        
        self.progressBarLayer.addAnimation(group, forKey: "animation")
        
    }

    
    
    
    func LoadingAnimation() {
        
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 1.0
        pathAnimation.fromValue = lastProgress
        pathAnimation.toValue = progress
        pathAnimation.delegate = self
        pathAnimation.setValue("loading", forKey: "animationName")
        pathAnimation.removedOnCompletion = false
        pathAnimation.fillMode = kCAFillModeForwards

        progressLayer.addAnimation(pathAnimation, forKey: nil)
        lastProgress = progress
    }
    
    func checkAnimation() {
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 0.35
        pathAnimation.fromValue = 0
        pathAnimation.toValue = 1
        pathAnimation.delegate = self
        pathAnimation.setValue("check", forKey: "animationName")
        pathAnimation.removedOnCompletion = false
        pathAnimation.fillMode = kCAFillModeForwards
        
        successLayer.addAnimation(pathAnimation, forKey: nil)
    }
    
    override init(frame: CGRect) {

        super.init(frame: frame)
        layer.masksToBounds = true
        self.originTitleColor = self.currentTitleColor
        self.layer.addSublayer(self.progressBarLayer)
        self.layer.addSublayer(self.progressLayer)
        
        
        print(self.originTitleColor)
        print(self.backgroundColor)


    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        layer.masksToBounds = true
        self.originTitleColor = self.currentTitleColor
        self.layer.addSublayer(self.progressBarLayer)
        self.layer.addSublayer(self.progressLayer)
        
        print(self.originTitleColor)
        print(self.backgroundColor)

    }
    

}

extension SubmitButton {
    
    // MARK : CAAnimationDelegate
    override func animationDidStart(anim: CAAnimation) {
        
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
     
        let animName = anim.valueForKey("animationName") as! String
        
        switch animName {
        case "startLoading":
            if let stateChanged = self.stateChanged {
                stateChanged(toState: .Loading)
            }
            break;
        case "loading":
            if(self.progress == 1) {
                self.resetProgress()
                self.changeState(.Finished)
                if let stateChanged = self.stateChanged {
                    stateChanged(toState: .Finished)
                }
            }
        case "success":
            self.resetProgressBar()

        default:
            break;
        }
    }
}

