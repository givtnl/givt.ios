//
//  MenuNavigationViewController.swift
//  ios
//
//  Created by Maarten Vergouwe on 18/12/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit
import LGSideMenuController

class MenuNavigationViewController: UINavigationController  {
    let slideAnimator = CustomPresentModalAnimation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor = #colorLiteral(red: 0.9370916486, green: 0.9369438291, blue: 0.9575446248, alpha: 1)
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
    }
}
