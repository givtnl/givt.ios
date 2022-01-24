//
//  RegistrationNavigationController.swift
//  ios
//
//  Created by Lennie Stockman on 22/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class RegNavigationController: UINavigationController {

    enum StartPoint {
        case registration
        case permission
        case amountLimit
        case mandate
    }
    
    var startPoint: StartPoint?
    var isRegistration = true
    override func viewDidLoad() {
        super.viewDidLoad()

        if startPoint == .permission {
            let vc = storyboard?.instantiateViewController(withIdentifier: "PermissionViewController") as! PermissionViewController
            vc.hasBackButton = true
            self.setViewControllers([vc], animated: false)
        } else if startPoint == .amountLimit && !isRegistration { //only show amountlimit when not registration flow
            let vc = storyboard?.instantiateViewController(withIdentifier: "alvcreg") as! AmountLimitViewController
            vc.hasBackButton = true
            self.setViewControllers([vc], animated: false)
        } else if startPoint == .mandate {
            if UserDefaults.standard.accountType == AccountType.bacs {
                self.removeLogo()
                let vc = UIStoryboard(name: "BACS", bundle: nil).instantiateViewController(withIdentifier: "BacsSettingUpViewController") as! BacsSettingUpViewController
                self.setViewControllers([vc], animated: false)
            } else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SPInfoViewController") as! SPInfoViewController
                vc.hasBackButton = true
                self.setViewControllers([vc], animated: false)
            }
        } else if startPoint == nil || startPoint == .registration  {
            if (try? Mediater.shared.send(request: GetCountryQuery())) == "US" {
                let vc = storyboard?.instantiateViewController(withIdentifier: "USRegistrationEmailPW") as! USRegistrationViewController
                self.setViewControllers([vc], animated: false)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
