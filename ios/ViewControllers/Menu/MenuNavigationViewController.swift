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
        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor.groupTableViewBackground
            appearance.shadowColor = UIColor.groupTableViewBackground
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
        } else {
            navigationBar.barTintColor = UIColor.groupTableViewBackground
            navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationBar.shadowImage = UIImage()
        }
    }
}
