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
    private var logService = LogService.shared
    
    private init() {

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
    
    public func loadMainPage(animated: Bool = true) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let childViewControllers = appDelegate.window?.rootViewController?.childViewControllers {
            for childViewController in childViewControllers {
                if let vc = childViewController as? CustomViewController {
                     load(vc: vc, animated: animated)
                }
            }
        }
    }
    
    public func load(vc: UINavigationController, animated: Bool = true) {
        DispatchQueue.main.async {
            if self.loginManager.userClaim == .startedApp {
                let welcome = UIStoryboard(name: "Welcome", bundle: nil).instantiateViewController(withIdentifier: "FirstUseViewController") as! FirstUseViewController
                vc.setViewControllers([welcome], animated: animated)
            } else {
                let amount = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AmountViewController") as! AmountViewController
                vc.setViewControllers([amount], animated: animated)
            }
        }
        
    }
    
    public func hasInternetConnection(context: UIViewController) -> Bool {
        if !AppServices.shared.connectedToNetwork() {
            let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("ConnectionError", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            }))
            context.present(alert, animated: true, completion:  {})
        }
        return AppServices.shared.connectedToNetwork()
        
    }
    
    public func pushWithLogin(_ vc: UIViewController, context: UIViewController) {  
        if hasInternetConnection(context: context) {
            if !LoginManager.shared.isBearerStillValid {
                if UserDefaults.standard.hasPinSet {
                    let pinVC = UIStoryboard(name: "Pincode", bundle: nil).instantiateViewController(withIdentifier: "PinNavViewController") as! PinNavViewController
                    pinVC.typeOfPin = .login
                    let completionHandler:(Bool)->Void = { status in
                        if status {
                            DispatchQueue.main.async {
                                context.present(vc, animated: true, completion: nil)
                            }
                        } else {
                            self.pushWithLogin(vc, context: context)
                        }

                    }
                    pinVC.outerHandler = completionHandler
                    context.present(pinVC, animated: true, completion: nil)
                    
                } else {
                    let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ncLogin") as! LoginNavigationViewController
                    let completionHandler:()->Void = {
                        DispatchQueue.main.async {
                            context.present(vc, animated: true, completion: nil)
                        }
                    }
                    loginVC.outerHandler = completionHandler
                    context.present(loginVC, animated: true, completion: nil)
                }
                
            } else {
                context.present(vc, animated: true)
            }
        }
    }
    
    
    private var isUpdateDialogOpen = false {
        didSet {
            print(isUpdateDialogOpen)
        }
    }
    public func resume() {
        if !isUpdateDialogOpen {
            showUpdateAlert()
        }
    }
    
    private var topController: UIViewController? {
        get {
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                return topController
            } else {
                return nil
            }
        }
    }
    
    fileprivate func showUpdate(critical: Bool) {
        let storeMessage = "\n\n" + NSLocalizedString("AppStoreRestart", comment: "")
        var alertTitle = ""
        var alertMessage = ""
        let downloadAction = UIAlertAction(title: "Download", style: .default, handler: { (action) in
            self.isUpdateDialogOpen = false
            UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/id1181435988")!)
        })
        var secundaryAction: UIAlertAction = UIAlertAction()
        
        if critical {
            alertTitle = NSLocalizedString("CriticalUpdateTitle", comment: "")
            alertMessage = NSLocalizedString("CriticalUpdateMessage", comment: "") + storeMessage
            secundaryAction = UIAlertAction(title: NSLocalizedString("MoreInfo", comment: ""), style: .default, handler: { (action) in
                self.isUpdateDialogOpen = false
                UIApplication.shared.openURL(URL(string: "https://www.givtapp.net/updates-app/")!)
            })
        } else {
            alertTitle = NSLocalizedString("UpdateAlertTitle", comment: "")
            alertMessage = NSLocalizedString("UpdateAlertMessage", comment: "") + storeMessage
            secundaryAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                self.isUpdateDialogOpen = false
            })
        }
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(secundaryAction)
        alert.addAction(downloadAction)
        DispatchQueue.main.async {
            self.topController?.present(alert, animated: false, completion: {
                self.isUpdateDialogOpen = true
            })
        }
    }
    
    public func showUpdateAlert() {
        
        DispatchQueue.main.async {
            
            self.topController?.view.isUserInteractionEnabled = !UserDefaults.standard.needsCriticalUpdate
            
            if AppServices.shared.connectedToNetwork() {
                InfraManager.shared.checkUpdates { (isCritical) in
                    guard let isCritical = isCritical else {
                        UserDefaults.standard.needsCriticalUpdate = false
                        return
                    }
                    self.logService.warning(message: "Depcrecated app used")
                    if isCritical {
                        UserDefaults.standard.needsCriticalUpdate = true
                        self.showUpdate(critical: true)
                    } else {
                        UserDefaults.standard.needsCriticalUpdate = false
                        self.showUpdate(critical: false)
                    }
                    
                    self.topController?.view.isUserInteractionEnabled = !UserDefaults.standard.needsCriticalUpdate
                }
            } else {
                if UserDefaults.standard.needsCriticalUpdate {
                    self.showUpdate(critical: true)
                } else {
                    self.topController?.view.isUserInteractionEnabled = !UserDefaults.standard.needsCriticalUpdate
                }
            }
            
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
