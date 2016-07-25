//
//  ViewController.swift
//  WXBubbleButton
//
//  Created by 魏翔 on 16/7/25.
//  Copyright © 2016年 魏翔. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
     
        super.viewDidLoad()

        let btn = WXBubbleButton()
        
        btn.title = "11"
        
        btn.frame = CGRectMake(100, 100, 20, 20)
        
        btn.showIn(view)
    }

}

