//
//  CustomViewController.swift
//  ios
//
//  Created by Lennie Stockman on 12/07/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import LGSideMenuController

class CustomViewController: UINavigationController  {
    weak var delegateTest: LGSideMenuDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        NavigationManager.shared.load(vc: self, animated: false)
    }
    
    @IBAction func unwindToAmount(segue: UIStoryboardSegue) {
        
    }
}
