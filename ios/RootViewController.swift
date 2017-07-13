//
//  RootViewController.swift
//  ios
//
//  Created by Maarten Vergouwe on 11/07/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import LGSideMenuController

class RootViewController: UIViewController, UIPageViewControllerDelegate {
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    var pageViewController: UIPageViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

