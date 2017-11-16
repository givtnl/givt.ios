//
//  NavigationManager.swift
//  ios
//
//  Created by Lennie Stockman on 25/10/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
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
        let vc = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "registration") as! RegNavigationController
        permissionAsked { (asked) in
            if UserDefaults.standard.tempUser { //tempuser
                vc.startPoint = .registration
                self.pushOnMainPage(context, vc)
            } else if !asked {
                vc.startPoint = .permission
                self.pushOnMainPage(context, vc)
            } else if !self.appSettings.mandateSigned {
                vc.startPoint = .mandate
                self.pushOnMainPage(context, vc)
            }
        }
        
        
    }
    
    private func pushOnMainPage(_ context: UIViewController, _ vc: UIViewController) {
        DispatchQueue.main.async {
            context.present(vc, animated: true, completion: nil)
        }
        
    }
    
    public func loadMainPage(_ navCtrl: UINavigationController, animated: Bool = true) {
        
        if loginManager.userClaim == .startedApp {
            let welcome = UIStoryboard(name: "Welcome", bundle: nil).instantiateViewController(withIdentifier: "FirstUseViewController") as! FirstUseViewController
            navCtrl.setViewControllers([welcome], animated: animated)
        } else {
            let amount = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AmountViewController") as! AmountViewController
            navCtrl.setViewControllers([amount], animated: animated)
        }
    }
    
    private func permissionAsked(completionHandler: @escaping (Bool) -> Void) {
        if #available(iOS 10.0, *) {
            let current = UNUserNotificationCenter.current()
            
            current.getNotificationSettings { (settings) in
                if settings.authorizationStatus == .notDetermined {
                    completionHandler(false)
                }
                
                if settings.authorizationStatus == .denied {
                    completionHandler(true)
                }
                
                if settings.authorizationStatus == .authorized {
                    completionHandler(true)
                }
            }
        } else {
            //fallback
            guard let settings = UIApplication.shared.currentUserNotificationSettings else {
                completionHandler(false)
                return
            }
            completionHandler(UIApplication.shared.isRegisteredForRemoteNotifications && !settings.types.isEmpty)
        }
        
    }
    
}
