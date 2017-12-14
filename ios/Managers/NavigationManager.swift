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
    private let _appServices = AppServices.shared
    
    private init() {

    }
   
    private var currentAlert: UIAlertController?
    public func finishRegistrationAlert(_ context: UIViewController) {
        if !loginManager.isFullyRegistered && loginManager.userClaim != .giveOnce {
            
            if let alert = self.currentAlert, self.currentAlert == self.topController?.presentedViewController {
                self.currentAlert!.dismiss(animated: false, completion: nil)
                self.currentAlert = nil
            }
            
            
            currentAlert = UIAlertController(title: NSLocalizedString("ImportantReminder", comment: ""), message: NSLocalizedString("FinalizeRegistrationPopupText", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            currentAlert?.addAction(UIAlertAction(title: NSLocalizedString("AskMeLater", comment: ""), style: UIAlertActionStyle.default, handler: { action in  }))
            currentAlert?.addAction(UIAlertAction(title: NSLocalizedString("FinalizeRegistration", comment: ""), style: .cancel, handler: { (action) in
                self.finishRegistration(context)
            }))
            context.present(currentAlert!, animated: false, completion: {})
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
                vc.setViewControllers([welcome], animated: false)
            } else {
                let amount = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AmountViewController") as! AmountViewController
                vc.setViewControllers([amount], animated: animated)
            }
        }
        
    }
    
    public func hasInternetConnection(context: UIViewController) -> Bool {
        if !AppServices.shared.connectedToNetwork() {
            presentAlertNoConnection(context: context)
        }
        return AppServices.shared.connectedToNetwork()
        
    }
    
    public func presentAlertNoConnection(context: UIViewController) {
        let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("ConnectionError", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
        }))
        context.present(alert, animated: true, completion:  {})
    }
    
    public func pushWithLogin(_ vc: UIViewController, context: UIViewController) {
        if !_appServices.connectedToNetwork() {
            presentAlertNoConnection(context: context)
            return
        }
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
                return topController
            } else {
                return nil
            }
        }
    }
    
    fileprivate func showUpdate(critical: Bool) {
        let storeMessage = "\n\n" + NSLocalizedString("AppStoreRestart", comment: "")
        
        var downloadAction: UIAlertAction = UIAlertAction()
        var secundaryAction: UIAlertAction = UIAlertAction()
        
        
        DispatchQueue.main.async {
            if let alert = self.currentAlert, self.currentAlert == self.topController?.presentedViewController {
                self.currentAlert!.dismiss(animated: false, completion: nil)
                self.currentAlert = nil
            }
        }
        
        currentAlert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        if critical {

            currentAlert?.title = NSLocalizedString("CriticalUpdateTitle", comment: "")
            currentAlert?.message = NSLocalizedString("CriticalUpdateMessage", comment: "") + storeMessage
            secundaryAction = UIAlertAction(title: NSLocalizedString("MoreInfo", comment: ""), style: .cancel, handler: { (action) in
                self.isUpdateDialogOpen = false
                UIApplication.shared.openURL(URL(string: "https://www.givtapp.net/updates-app/")!)
                UIApplication.shared.beginIgnoringInteractionEvents()
            })
            downloadAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.isUpdateDialogOpen = false
                UIApplication.shared.beginIgnoringInteractionEvents()
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: AppConstants.appStoreUrl)!, options: [:], completionHandler: { (status) in
                        print(status)
                    })
                } else {
                    UIApplication.shared.openURL(URL(string: AppConstants.appStoreUrl)!)
                }
            })
        } else {
            UIApplication.shared.endIgnoringInteractionEvents()
            currentAlert?.title = NSLocalizedString("UpdateAlertTitle", comment: "")
            currentAlert?.message = NSLocalizedString("UpdateAlertMessage", comment: "") + storeMessage
            secundaryAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                self.isUpdateDialogOpen = false
            })
            downloadAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.isUpdateDialogOpen = false
                DispatchQueue.main.async {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(URL(string: AppConstants.appStoreUrl)!, options: [:], completionHandler: { (status) in
                            print(status)
                        })
                    } else {
                        UIApplication.shared.openURL(URL(string: AppConstants.appStoreUrl)!)
                    }
                }
                
            })
        }
        
        
        currentAlert?.addAction(secundaryAction)
        currentAlert?.addAction(downloadAction)
        DispatchQueue.main.async {
            UIApplication.shared.endIgnoringInteractionEvents()
            self.topController?.present(self.currentAlert!, animated: false, completion: {
                self.isUpdateDialogOpen = true
            })
        }
    }
    
    
    
    public func showUpdateAlert() {
        
        DispatchQueue.main.async {
            if AppServices.shared.connectedToNetwork() {
                InfraManager.shared.checkUpdates { (isCritical) in
                    guard let isCritical = isCritical else {
                        UserDefaults.standard.needsCriticalUpdate = false
                        DispatchQueue.main.async {
                            UIApplication.shared.endIgnoringInteractionEvents()
                        }
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
                }
            } else {
                if UserDefaults.standard.needsCriticalUpdate {
                    self.showUpdate(critical: true)
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
