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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let frame = CGRect(x: 50, y: 100, width: 200, height: 80)
        button = SubmitButton(frame: frame)
        button.layer.cornerRadius = 5
        
//        button.conr
        button.backgroundColor = UIColor(red:0, green:206/255, blue:148/255, alpha:1)
        button.setTitle("Submit", forState: .Normal)
        self.view.addSubview(button)
    }
    @IBAction func start(sender: AnyObject) {
        button.startLoadingAnimation(.Loading)
    }
    @IBAction func loading2Action(sender: AnyObject) {
        button.progress = 1

    }

    @IBAction func loadingAction(sender: AnyObject) {
        button.progress = 0.5
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

