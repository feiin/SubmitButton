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
}


class SubmitButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
//    var cornerRadius: CGFloat = 0
    var originalColor: CGColorRef = UIColor(red:0, green:206/255, blue:148/255, alpha:1).CGColor
    var originalBorderColor: CGColorRef = UIColor(red:0, green:206/255, blue:148/255, alpha:1).CGColor
    private var borderWidth: CGFloat = 5.0

    
    
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
    
    
    private func circlePath() -> UIBezierPath {
        let radius = originHeight / 2
        let arcCenter = CGPoint(x: radius, y: radius)
        let startAngle = CGFloat(-M_PI_2)
        let endAngle = startAngle + CGFloat(M_PI*2)
        let path = UIBezierPath(arcCenter: arcCenter, radius: radius - borderWidth/2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        return path
    }
    
    
    private lazy var progressBarLayer:CALayer = {
        var layer = CALayer()
        var x = (self.layer.bounds.width - self.layer.bounds.height) / 2
        layer.frame = CGRectMake(0, 0, self.layer.bounds.width, self.layer.bounds.height)
//        layer.bounds  = CGRectZero

        layer.masksToBounds = true
        layer.cornerRadius = 0
        layer.backgroundColor = self.layer.backgroundColor
        layer.borderWidth  = self.borderWidth
        layer.borderColor =  self.originalColor

        return layer
     }()
    
    
    
    private lazy var progressLayer: CAShapeLayer = {
        var layer = CAShapeLayer()
        var x = (self.layer.bounds.width - self.layer.bounds.height) / 2
        
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
        layer.lineWidth  = self.borderWidth
        layer.borderColor = UIColor.clearColor().CGColor

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
            
//            progressLayer.strokeEnd = progress
            LoadingAnimation()
        }
    }
    

    func changeState(toState: SubmitButtonState ) {
        
    }
    
    func startLoadingAnimation(state: SubmitButtonState) {

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
    
    override init(frame: CGRect) {

        super.init(frame: frame)
        layer.masksToBounds = true

        self.layer.addSublayer(self.progressBarLayer)
        self.layer.addSublayer(self.progressLayer)


    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    

}

extension SubmitButton {
    
    // MARK : CAAnimationDelegate
    override func animationDidStart(anim: CAAnimation) {
        
        
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        
    }
}

