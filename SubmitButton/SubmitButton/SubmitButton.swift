//
//  SubmitButton.swift
//  SubmitButton
//
//  Created by yangyin on 16/7/22.
//  Copyright © 2016年 swiftmi. All rights reserved.
//

import UIKit

enum SubmitButtonState: Int {
    case Normal = 0
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
   @IBInspectable var progressBorderWidth: CGFloat = 5.0
   @IBInspectable var successColor:UIColor = UIColor(red:0, green:206/255, blue:148/255, alpha:1)
   @IBInspectable var progressColor:UIColor = UIColor(red:0, green:206/255, blue:148/255, alpha:1) {
        didSet {
            self.progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
  
    var submitState:SubmitButtonState {
        get {
            return btnState
        }
    }
    
    var stateChanged:((_ toState: SubmitButtonState)->Void)? = nil
    
    private var originalColor: CGColor?
    private var originalBorderColor: CGColor?
    private var originTitleColor:UIColor!
    
    private var btnState:SubmitButtonState = .Normal
    
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
        
        
        let point1 = CGPoint(x: rect.origin.x + rect.size.width*2 / 10, y: rect.origin.y + rect.size.height*2 / 3)
        let point2 = CGPoint(x: rect.origin.x + rect.size.width / 3, y:rect.origin.y + rect.size.height*8 / 10)
        
        let point3 = CGPoint(x: rect.origin.x + rect.size.width*8 / 10, y: rect.origin.y + rect.size.height*3 / 10)
        path.move(to: point1)
        path.addLine(to: point2)
        path.addLine(to: point3)
        return path
        
    }
    
    private lazy var progressBarLayer:CALayer = {
        let layer = CALayer()
        let x = (self.layer.bounds.width - self.layer.bounds.height) / 2
    
        layer.frame = CGRect(x: 0, y: 0, width: self.layer.bounds.width, height: self.layer.bounds.height)
 
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
        
        layer.frame = CGRect(x:x, y:0, width:self.layer.bounds.height, height: self.layer.bounds.height)
        layer.bounds  = self.loadingBounds
        layer.path = self.circlePath().cgPath
        layer.strokeEnd = 0
        layer.strokeStart = 0
        layer.strokeColor = self.progressColor.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.masksToBounds = true
        layer.cornerRadius = self.loadingCornerRadius
        layer.backgroundColor = UIColor.clear.cgColor
        layer.lineWidth  = self.progressBorderWidth
        layer.borderColor = UIColor.clear.cgColor
        
        return layer
        
    }()
    
    private func resetLayer ()
    {
        self.backgroundColor =  UIColor(cgColor: self.originalColor!)
        self.layer.borderColor =  self.originalBorderColor
        self.setTitleColor(self.originTitleColor, for: UIControlState.normal)
    }
    
    
    internal func resetProgress ()
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
        layer.path = self.successPath().cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.cgColor
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
        }
    }
    

    func changeState(toState: SubmitButtonState) {
        
        self.btnState = toState
        
        switch toState {
        case .Normal:
            
            self.resetProgress()
            self.resetProgressBar()
            self.resetSuccessLayer()
            self.resetLayer()
            self.progressLayer.removeFromSuperlayer()
            self.progressBarLayer.removeFromSuperlayer()
            if let stateChanged = self.stateChanged {
                stateChanged(.Normal)
            }
        case .Loading:
            
            self.initOriginColor()
             self.layer.addSublayer(self.progressBarLayer)
            self.layer.addSublayer(self.progressLayer)
            
            self.resetSuccessLayer()
            startLoadingAnimation()
        case .Finished:
            self.layer.addSublayer(successLayer)
            successAnimation()
            self.checkAnimation()
        case .Error:
            break
        }
        
        if toState != .Normal
        {
            self.setTitleColor(UIColor.clear, for: .normal)
        }
    }
    
    private func startLoadingAnimation() {

        let group = CAAnimationGroup()
        group.duration = 0.5
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        group.beginTime = CACurrentMediaTime() + 0.1
        group.fillMode = kCAFillModeForwards
        group.isRemovedOnCompletion = false
        group.delegate = self
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.layer.borderColor = UIColor.clear.cgColor

        group.setValue("startLoading", forKey: "animationName")
        group.setValue(self.progressBarLayer, forKey: "layer")
        
        // frame
        let sizeAnimation = CABasicAnimation(keyPath: "frame")
        let x = (self.layer.bounds.width - self.layer.bounds.height) / 2
        let toFrame = CGRect(x:x, y:0, width: self.layer.bounds.height,height: self.layer.bounds.height)

        sizeAnimation.toValue = NSValue(cgRect: toFrame)
        
        // bounds
        let boundsAnimation = CABasicAnimation(keyPath: "bounds")
        boundsAnimation.toValue = NSValue(cgRect: self.loadingBounds)
        
        
        // cornerRadius
        let cornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        cornerRadiusAnimation.toValue = self.loadingCornerRadius
        
        // backgroundColor
        let backgroundColorAnimation = CABasicAnimation(keyPath: "backgroundColor")
        backgroundColorAnimation.toValue = UIColor.clear.cgColor
        
        // borderColor
        let borderColorAnimation = CABasicAnimation(keyPath: "borderColor")
         borderColorAnimation.fromValue = self.originalColor
         borderColorAnimation.toValue = UIColor.gray.cgColor
        
        group.animations = [sizeAnimation, boundsAnimation , cornerRadiusAnimation, backgroundColorAnimation, borderColorAnimation]
        
        self.progressBarLayer.add(group, forKey: "anim")
        
    }
    
    private func successAnimation() {
        
        let group = CAAnimationGroup()
        group.duration = 0.5
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        group.beginTime = CACurrentMediaTime() + 0.1
        group.fillMode = kCAFillModeForwards
        group.isRemovedOnCompletion = false
        group.delegate = self
        
        group.setValue("success", forKey: "animationName")
        group.setValue(self.progressBarLayer, forKey: "layer")
        
        // frame
        let sizeAnimation = CABasicAnimation(keyPath: "frame")
        let toFrame = CGRect(x:0, y: 0, width:self.layer.bounds.width,height: self.layer.bounds.height)
        
        sizeAnimation.toValue = NSValue(cgRect: toFrame)
        
        // bounds
        let boundsAnimation = CABasicAnimation(keyPath: "bounds")
        boundsAnimation.toValue = NSValue(cgRect: self.originBounds)
        
        
        // cornerRadius
        let cornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        cornerRadiusAnimation.toValue = self.originCornerRadius
        
        // backgroundColor
        let backgroundColorAnimation = CABasicAnimation(keyPath: "backgroundColor")
        backgroundColorAnimation.toValue = self.successColor.cgColor
        // borderColor
        let borderColorAnimation = CABasicAnimation(keyPath: "borderColor")
        borderColorAnimation.fromValue = self.successColor.cgColor
        borderColorAnimation.toValue = self.successColor.cgColor
    
        group.animations = [sizeAnimation, boundsAnimation , cornerRadiusAnimation, backgroundColorAnimation, borderColorAnimation]
        
        self.progressBarLayer.add(group, forKey: "animation")
        
    }
    
   private func LoadingAnimation() {
        
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 1.0
        pathAnimation.fromValue = lastProgress
        pathAnimation.toValue = progress
        pathAnimation.delegate = self
        pathAnimation.setValue("loading", forKey: "animationName")
        pathAnimation.isRemovedOnCompletion = false
        pathAnimation.fillMode = kCAFillModeForwards

        progressLayer.add(pathAnimation, forKey: nil)
        lastProgress = progress
    }
    
   private func checkAnimation() {
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 0.35
        pathAnimation.fromValue = 0
        pathAnimation.toValue = 1
        pathAnimation.delegate = self
        pathAnimation.setValue("check", forKey: "animationName")
        pathAnimation.isRemovedOnCompletion = false
        pathAnimation.fillMode = kCAFillModeForwards
        
        successLayer.add(pathAnimation, forKey: nil)
    }
    
    private  func initOriginColor() {
    
        if self.originalColor != nil  {
            //only init first time
            return
        }
    
        self.originTitleColor = self.currentTitleColor
        if let bgColor = self.backgroundColor {
            self.originalColor = bgColor.cgColor
        } else {
            self.originalColor = UIColor.clear.cgColor
            
        }
        
        if let borderColor = self.layer.borderColor {
            self.originalBorderColor = borderColor
        } else {
            self.originalBorderColor = UIColor.clear.cgColor
        }

    }
    
    override init(frame: CGRect) {

        super.init(frame: frame)
        layer.masksToBounds = true
        self.originTitleColor = self.currentTitleColor
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        layer.masksToBounds = true
        self.originTitleColor = self.currentTitleColor
    }
    
 
}

extension SubmitButton: CAAnimationDelegate {
    
    // MARK : CAAnimationDelegate
    
    func animationDidStart(_ anim: CAAnimation) {
//        let animName = anim.valueForKey("animationName") as! String
 
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
     
        let animName = anim.value(forKey:"animationName") as! String
        
        switch animName {
        case "startLoading":
        
            if let stateChanged = self.stateChanged {
                stateChanged(.Loading)
            }
            break;
        case "loading":
            if(self.progress == 1) {
                
                self.resetProgress()
                self.changeState(toState: .Finished)
                if let stateChanged = self.stateChanged {
                    stateChanged(.Finished)
                }
            }
            
        case "success":
            break;
        default:
            break;
        }
        
    }
}

