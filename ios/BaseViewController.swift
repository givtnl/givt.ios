//
//  AmountViewController.swift
//  ios
//
//  Created by Lennie Stockman on 12/07/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import LGSideMenuController


class BaseViewController: LGSideMenuController, LGSideMenuDelegate {
    
    private var navigationManager: NavigationManager = NavigationManager.shared
    
    func willShowLeftView(_ leftView: UIView, sideMenuController: LGSideMenuController) {
        UIApplication.shared.statusBarStyle = .default
        if let vc = UIApplication.shared.keyWindow?.rootViewController?.childViewControllers.first as? SettingTableViewController {
            vc.loadSettings()
        }
    }
    
    func willHideLeftView(_ leftView: UIView, sideMenuController: LGSideMenuController) {
        UIApplication.shared.statusBarStyle = .default
    }

    override func viewDidLoad() {
        super.delegate = self
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
        
    }
    

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
