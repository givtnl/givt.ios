//
//  NavigationManager.swift
//  ios
//
//  Created by Lennie Stockman on 25/10/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import Foundation
import UIKit
class NavigationManager {
    static let shared = NavigationManager()
    private var loginManager: LoginManager = LoginManager.shared
    private var appSettings = UserDefaults.standard
    
    private init() {
        print("started navigationManager")
    }
    
    public func finishRegistrationAlert(_ context: UIViewController) {
        if !loginManager.isFullyRegistered && loginManager.userClaim != .giveOnce {
            
            let alert = UIAlertController(title: NSLocalizedString("ImportantReminder", comment: ""), message: NSLocalizedString("FinalizeRegistrationPopupText", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("AskMeLater", comment: ""), style: UIAlertActionStyle.default, handler: { action in  }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("FinalizeRegistration", comment: ""), style: .cancel, handler: { (action) in
                self.finishRegistration(context)
            }))
            context.present(alert, animated: true, completion: {})
        }
    }
    
    public func finishRegistration(_ context: UIViewController) {
        if self.appSettings.amountLimit == .max { //tempuser
            let vc = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "registration") as! RegNavigationController
            context.present(vc, animated: true, completion: nil)
        } else if self.appSettings.amountLimit == -1 { //user quit just before entering amount limit
            let vc = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "registration") as! RegNavigationController
            vc.startPoint = .amountLimit
            context.present(vc, animated: true, completion: nil)
        } else if !self.appSettings.mandateSigned {
            let vc = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "registration") as! RegNavigationController
            vc.startPoint = .mandate
            context.present(vc, animated: true, completion: nil)
        }
    }
    
    public func loadMainPage(_ context: UIViewController) {
        if loginManager.userClaim == .startedApp {
            let welcome = UIStoryboard(name: "Welcome", bundle: nil).instantiateViewController(withIdentifier: "FirstUseNavigationViewController") as! FirstUseNavigationViewController
            context.present(welcome, animated: false, completion: nil)
        }
    }
    
}
