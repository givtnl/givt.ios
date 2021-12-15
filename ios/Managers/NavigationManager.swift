
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
import LocalAuthentication
class NavigationManager {
    static let shared = NavigationManager()
    private var loginManager: LoginManager = LoginManager.shared
    private var givtService: GivtManager {
        get {
            return GivtManager.shared
        }
    }
    private var appSettings = UserDefaults.standard
    private var logService = LogService.shared
    private let _appServices = AppServices.shared
    private let slideFromRightAnimation = PresentFromRight()
    
    var delegate: NavigationManagerDelegate?
    
    private init() { }
    
    private var currentAlert: UIAlertController?
    public func finishRegistrationAlert(_ context: UIViewController) {
        if !loginManager.isFullyRegistered && loginManager.userClaim != .giveOnce {
            
            if let alert = self.currentAlert, alert == self.topController?.presentedViewController {
                self.currentAlert!.dismiss(animated: false, completion: nil)
                self.currentAlert = nil
            }  
            
            currentAlert = UIAlertController(title: NSLocalizedString("ImportantReminder", comment: ""), message: NSLocalizedString("FinalizeRegistrationPopupText", comment: ""), preferredStyle: UIAlertController.Style.alert)
            currentAlert?.addAction(UIAlertAction(title: NSLocalizedString("AskMeLater", comment: ""), style: UIAlertAction.Style.default, handler: { action in
                if let ctx = context as? MainViewController {
                    ctx.menu.image = LoginManager.shared.isFullyRegistered ? #imageLiteral(resourceName: "menu_base") : #imageLiteral(resourceName: "menu_badge")
                }
            }))
            currentAlert?.addAction(UIAlertAction(title: NSLocalizedString("FinalizeRegistration", comment: ""), style: .cancel, handler: { (action) in
                if let ctx = context as? MainViewController {
                    ctx.menu.image = LoginManager.shared.isFullyRegistered ? #imageLiteral(resourceName: "menu_base") : #imageLiteral(resourceName: "menu_badge")
                }
                
                if AppServices.shared.isServerReachable {
                    self.finishRegistration(context)
                } else {
                    self.presentAlertNoConnection(context: context)
                }
                
            }))
            context.present(currentAlert!, animated: false, completion: {})
        }
    }
    
    public func finishRegistration(_ context: UIViewController) {
        let vc = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "registration") as! RegNavigationController
        vc.transitioningDelegate = slideFromRightAnimation
        vc.modalPresentationStyle = .fullScreen
        if let userExt = UserDefaults.standard.userExt {
            LoginManager.shared.doesEmailExist(email: userExt.email) { (status) in
                if status == "true" { //completed registration
                    UserDefaults.standard.isTempUser = false
                } else if status == "false" { //email is completely new
                    UserDefaults.standard.isTempUser = true
                } else if status == "temp" || status == "dashboard" { //email is in db but not succesfully registered
                    UserDefaults.standard.isTempUser = true
                }
                
                self.permissionAsked { (asked) in
                    if UserDefaults.standard.isTempUser { //tempuser
                        vc.startPoint = .registration
                        self.pushOnMainPage(context, vc)
                    } else if !asked {
                        vc.startPoint = .permission
                        self.pushWithLogin(vc, context: context)
                    } else if !self.appSettings.mandateSigned {
                        vc.startPoint = .mandate
                        self.pushWithLogin(vc, context: context)
                    }
                }
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
        if let childViewControllers = appDelegate.window?.rootViewController?.children {
            for childViewController in childViewControllers {
                if let vc = childViewController as? MainNavigationController {
                    load(vc: vc, animated: animated)
                }
            }
        }
    }
    
    public func loadHistoryPage(animated: Bool = true) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let childViewControllers = appDelegate.window?.rootViewController?.children {
            for childViewController in childViewControllers {
                if let vc = childViewController as? MainNavigationController {
                    loadHistory(vc: vc, animated: animated)
                }
            }
        }
    }
    
    public func loadHistory(vc: UINavigationController, animated: Bool = true) {
        DispatchQueue.main.async {
            let amount = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            amount.showHistory = true
            vc.setViewControllers([amount], animated: animated)
        }
    }
    
    public func load(vc: UINavigationController, animated: Bool = true) {
        var thisVersion = ""
        if let savedVersion = UserDefaults.standard.termsVersion {
            thisVersion = savedVersion
        } else {
            thisVersion = AppServices.isCountryFromSimGB() ? NSLocalizedString("TermsTextVersionGB", comment: "") : NSLocalizedString("TermsTextVersion", comment: "")
            UserDefaults.standard.termsVersion = thisVersion
        }
        DispatchQueue.main.async {
            
            if self.loginManager.userClaim == .startedApp {
                //force logout. TODO: remove this when users have been refactored
                self.loginManager.logout()
                let welcome = UIStoryboard(name: "Welcome", bundle: nil).instantiateViewController(withIdentifier: "FirstUseViewController") as! FirstUseViewController
                vc.setViewControllers([welcome], animated: false)
            } else {
                let onlineVersion = AppServices.isCountryFromSimGB() ? NSLocalizedString("TermsTextVersionGB", comment: "") : NSLocalizedString("TermsTextVersion", comment: "")
                if thisVersion != onlineVersion {
                    let termsUpdateVC = UIStoryboard(name: "UpdatedTermsPage", bundle: nil).instantiateInitialViewController() as! UpdatedTermsPageViewController
                    vc.setViewControllers([termsUpdateVC], animated: false)
                } else {
                    let amount = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                    vc.setViewControllers([amount], animated: animated)
                }
            }
        }
        
    }
    
    public func hasInternetConnection(context: UIViewController) -> Bool {
        if !AppServices.shared.isServerReachable {
            presentAlertNoConnection(context: context)
        }
        return AppServices.shared.isServerReachable        
    }
    
    public func presentAlertNoConnection(context: UIViewController) {
        let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("ConnectionError", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
        }))
        context.present(alert, animated: true, completion:  {})
    }
    
    public func pushWithLogin(_ vc: UIViewController, context: UIViewController) {
        executeWithLogin(context: context) {
            DispatchQueue.main.async {
                context.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    public func reAuthenticateIfNeeded(context: UIViewController, skipFingerprint: Bool = false, completion: @escaping () -> Void) {
        if !LoginManager.shared.isBearerStillValid {
            if UserDefaults.standard.hasFingerprintSet && !skipFingerprint {
                context.showLoader()
                self.loginManager.loginWithFingerprint { (success, status) in
                    DispatchQueue.main.async {
                        context.hideLoader()
                        if success {
                            completion()
                        } else {
                            if let status = status, status == errSecUserCanceled {
                                let cannotUseTouchId = UIAlertController(title: NSLocalizedString("Login", comment: ""), message: NSLocalizedString("CancelledAuthorizationMessage", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                cannotUseTouchId.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertAction.Style.default, handler: { (action) in
                                    self.reAuthenticateIfNeeded(context: context, skipFingerprint: true, completion: completion)
                                }))
                                cannotUseTouchId.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: UIAlertAction.Style.default, handler: nil))
                                context.present(cannotUseTouchId, animated: true, completion: nil)
                            } else {
                                let cannotUseTouchId = UIAlertController(title: NSLocalizedString("AuthenticationIssueTitle", comment: ""), message: NSLocalizedString("AuthenticationIssueFallbackMessage", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                cannotUseTouchId.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                                    self.reAuthenticateIfNeeded(context: context, skipFingerprint: true, completion: completion)
                                }))
                                context.present(cannotUseTouchId, animated: true, completion: nil)
                            }
                        }
                    }
                }
            } else if UserDefaults.standard.hasPinSet {
                let pinVC = UIStoryboard(name: "Pincode", bundle: nil).instantiateViewController(withIdentifier: "PinNavViewController") as! PinNavViewController
                pinVC.typeOfPin = .login
                pinVC.outerHandler = { status in
                    if !status {
                        self.reAuthenticateIfNeeded(context: context, completion: completion)
                    } else {
                        completion()
                    }
                    DispatchQueue.main.async {
                        context.present(pinVC, animated: true, completion: nil)
                    }
                }
            } else {
                let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ncLogin") as! LoginNavigationViewController
                loginVC.outerHandler = completion
                loginVC.emailEditable = false
                DispatchQueue.main.async {
                    context.present(loginVC, animated: true, completion: nil)
                }
            }
        } else {
            completion()
        }
    }
    
    public func executeWithLogin(context: UIViewController, emailEditable: Bool = false, skipFingerprint: Bool = false, completion: @escaping () -> Void) {
        if !_appServices.isServerReachable {
            presentAlertNoConnection(context: context)
            return
        }
        if !LoginManager.shared.isBearerStillValid {
            if UserDefaults.standard.hasFingerprintSet && !skipFingerprint {
                context.showLoader()
                self.loginManager.loginWithFingerprint { (success, status) in
                    DispatchQueue.main.async {
                        context.hideLoader()
                        if success {
                            completion()
                        } else {
                            if let status = status, status == errSecUserCanceled {
                                let cannotUseTouchId = UIAlertController(title: NSLocalizedString("Login", comment: ""), message: NSLocalizedString("CancelledAuthorizationMessage", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                cannotUseTouchId.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertAction.Style.default, handler: { (action) in
                                    self.executeWithLogin(context: context, emailEditable: emailEditable, skipFingerprint: true, completion: completion)
                                    UserDefaults.standard.hasFingerprintSet = false
                                }))
                                cannotUseTouchId.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: UIAlertAction.Style.default, handler: nil))
                                context.present(cannotUseTouchId, animated: true, completion: nil)
                            } else {
                                let cannotUseTouchId = UIAlertController(title: NSLocalizedString("AuthenticationIssueTitle", comment: ""), message: NSLocalizedString("AuthenticationIssueFallbackMessage", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                cannotUseTouchId.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                                    self.executeWithLogin(context: context, emailEditable: emailEditable, skipFingerprint: true, completion: completion)
                                }))
                                context.present(cannotUseTouchId, animated: true, completion: nil)
                            }
                        }
                    }
                }
            } else if UserDefaults.standard.hasPinSet {
                let pinVC = UIStoryboard(name: "Pincode", bundle: nil).instantiateViewController(withIdentifier: "PinNavViewController") as! PinNavViewController
                pinVC.typeOfPin = .login
                pinVC.outerHandler = { status in
                    if !status {
                        self.executeWithLogin(context: context, emailEditable: emailEditable, completion: completion)
                    } else {
                        completion()
                    }
                }
                DispatchQueue.main.async {
                    context.present(pinVC, animated: true, completion: {
                        context.sideMenuController?.hideLeftView(sender: context)
                    })
                }
            } else {
                let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ncLogin") as! LoginNavigationViewController
                loginVC.outerHandler = completion
                loginVC.emailEditable = emailEditable
                DispatchQueue.main.async {
                    context.present(loginVC, animated: true, completion: {
                        context.sideMenuController?.hideLeftView(sender: context)
                    })
                }
            }
        } else {
            completion()
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
        self.delegate?.willResume(sender: self)
    }
    
    private var topController: UIViewController? {
        get {
            if let topController = UIApplication.shared.keyWindow?.rootViewController {
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
            if let alert = self.currentAlert, alert == self.topController?.presentedViewController {
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
            if AppServices.shared.isServerReachable {
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

protocol NavigationManagerDelegate: class {
    func willResume(sender: NavigationManager)
}
