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
        // Do any additional setup after loading the view.
        /* LGSideMenuDelegate.didHideLeftView(<#T##LGSideMenuDelegate#>)
         delegateTest?.willHideLeftView(leftView: UIView, sideMenuController: LGSideMenuController) += NSLog("test")*/
        NavigationManager.shared.loadMainPage(animated: false)
    }
    
    @IBAction func unwindToAmount(segue: UIStoryboardSegue) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    
    
    
}
