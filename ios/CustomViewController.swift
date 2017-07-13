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
        // Do any additional setup after loading the view.
       /* LGSideMenuDelegate.didHideLeftView(<#T##LGSideMenuDelegate#>)
        delegateTest?.willHideLeftView(leftView: UIView, sideMenuController: LGSideMenuController) += NSLog("test")*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

}
