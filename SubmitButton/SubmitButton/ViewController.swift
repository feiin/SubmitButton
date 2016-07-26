//
//  ViewController.swift
//  SubmitButton
//
//  Created by yangyin on 16/7/22.
//  Copyright © 2016年 swiftmi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var button:SubmitButton!
    
    @IBOutlet weak var btn1: SubmitButton!
   
    @IBOutlet weak var btn2: SubmitButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let frame = CGRect(x: 50, y: 100, width: 200, height: 60)
        
        button = SubmitButton(frame: frame)
        button.layer.cornerRadius = 10
        button.checkLineWidth = 6
        
        button.backgroundColor = UIColor(red:0, green:206/255, blue:148/255, alpha:1)
        button.setTitle("Submit", forState: .Normal)
//        button.setTitleColor(UIColor.blueColor(), forState: .Normal)

        self.view.addSubview(button)
        btn1.progressColor = UIColor.redColor()
        btn1.stateChanged = {
            (toState:SubmitButtonState) in
            if toState == .Loading {
                self.btn1.progress  = 1
            }
         }
        
        btn3.layer.borderWidth = 5
        btn3.layer.borderColor = UIColor.redColor().CGColor
        btn2.stateChanged = {
            (toState:SubmitButtonState) in
            if toState == .Loading {
                self.btn2.progress  = 1
            }
        }
        
        btn3.stateChanged = {
            (toState:SubmitButtonState) in
            if toState == .Loading {
                self.btn3.progress  = 1
            }
        }
     }
    @IBOutlet weak var btn3: SubmitButton!
    
    @IBAction func btnClicked(sender: AnyObject) {
        let btn = sender as! SubmitButton
        if btn.submitState != .Normal  {
            btn.changeState(.Normal)

        } else {
            btn.changeState(.Loading)
        }
//        btn.progress = 1

    }
    
    @IBAction func btn2Click(sender: AnyObject) {
        let btn = sender as! SubmitButton
        if btn.submitState != .Normal  {
            btn.changeState(.Normal)
            
        } else {
            btn.changeState(.Loading)
        }
    }
    
    @IBAction func resetButton(sender: AnyObject) {
        button.changeState(.Normal)
    }
    
    @IBAction func start(sender: AnyObject) {
        button.changeState(.Loading)
    }
    
    
    @IBAction func loading2Finished(sender: AnyObject) {
        button.progress = 1

    }

    @IBAction func loadingProccess(sender: AnyObject) {
        button.progress = 0.5
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

