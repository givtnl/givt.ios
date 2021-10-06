//
//  AmountViewController.swift
//  ios
//
//  Created by Lennie Stockman on 12/07/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import LGSideMenuController

class FirstViewController: LGSideMenuController {
    func didTransformRootView(sideMenuController: LGSideMenuController, percentage: CGFloat) {}
    func didTransformLeftView(sideMenuController: LGSideMenuController, percentage: CGFloat) {}
    func didTransformRightView(sideMenuController: LGSideMenuController, percentage: CGFloat) {}
    
    func willShowLeftView(_ leftView: UIView, sideMenuController: LGSideMenuController) {
        UIApplication.shared.statusBarStyle = .default
//        if let vc = UIApplication.shared.keyWindow?.rootViewController?.childViewControllers.first as? SettingsViewController {
//            vc.loadItems()()
//        }
    }
    
    func willHideLeftView(_ leftView: UIView, sideMenuController: LGSideMenuController) {
        UIApplication.shared.statusBarStyle = .default
    }

    override func viewDidLoad() {
        UIApplication.shared.statusBarStyle = .default
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        leftViewPresentationStyle = .slideAside
    }
    

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
