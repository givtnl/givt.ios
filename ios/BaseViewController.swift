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
        if LoginManager.shared.userClaim == .startedApp
        {
            let welcome = UIStoryboard(name: "Welcome", bundle: nil).instantiateViewController(withIdentifier: "FirstUseNavigationViewController") as! FirstUseNavigationViewController
            self.present(welcome, animated: false, completion: nil)
            //self.present((self.storyboard?.instantiateViewController(withIdentifier: "ncLogin"))!, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier! == "root")
        {
//            let del = UIApplication.shared.delegate as! AppDelegate
//            del.mainNavigation? = segue.destination as! CustomViewController
//            print("test")
        }
    }
    

}
