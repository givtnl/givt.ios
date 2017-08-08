//
//  AmountViewController.swift
//  ios
//
//  Created by Lennie Stockman on 12/07/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import LGSideMenuController


class AmountViewController: LGSideMenuController, LGSideMenuDelegate {
    
    
    func willShowLeftView(_ leftView: UIView, sideMenuController: LGSideMenuController) {
        UIApplication.shared.statusBarStyle = .default
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
        let isLoggedIn = UserDefaults.standard.isLoggedIn()
        if(!isLoggedIn)
        {
            self.performSegue(withIdentifier: "loginView", sender: self)
        }
        
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
