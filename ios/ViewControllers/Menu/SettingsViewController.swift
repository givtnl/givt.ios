//
//  SettingsViewController.swift
//  ios
//
//  Created by Lennie Stockman on 10/01/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit
import SVProgressHUD
import AVFoundation

class SettingsViewController: BaseMenuViewController {
    var logService: LogService = LogService.shared
    private let slideFromRightAnimation = PresentFromRight()
    
    private var navigationManager = NavigationManager.shared

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navItem.leftBarButtonItem = nil
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
        
        NotificationCenter.default.addObserver(self, selector: #selector(badgeDidChange), name: .GivtBadgeNumberDidChange, object: nil)
    }
    
    @objc func badgeDidChange(notification:Notification) {
        loadItems()
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
    
    override func loadItems(){
        items = []        
        let changeAccount = Setting(name: NSLocalizedString("LogoffSession", comment: ""), image: UIImage(named: "exit")!, callback: { self.logout() }, showArrow: false)
        
        let appInfo = Setting(name: "The app from A to Z", image: UIImage(named: "givt_atoz")!, showBadge: FeatureManager.shared.showBadge, callback: { self.appInfo() })
        let aboutGivt = Setting(name: NSLocalizedString("TitleAboutGivt", comment: ""), image: UIImage(named: "info24")!, callback: { self.about() })
        let shareGivt = Setting(name: NSLocalizedString("ShareGivtText", comment: ""), image: UIImage(named: "share")!, callback: { self.share() }, showArrow: false)
        
        let finishRegistration = Setting(name: NSLocalizedString("FinalizeRegistration", comment: ""), image: #imageLiteral(resourceName: "pencil"), showBadge: true, callback: { self.register() })
        let changePersonalInfo = Setting(name: NSLocalizedString("TitlePersonalInfo", comment: ""), image: #imageLiteral(resourceName: "pencil"), showBadge: false, callback: { self.changePersonalInfo() })
        
        let amountPresets = Setting(name: NSLocalizedString("AmountPresetsTitle", comment: ""), image: #imageLiteral(resourceName: "amountpresets"), callback: { self.changeAmountPresets() }, showArrow: true)
        
        let screwAccount = Setting(name: NSLocalizedString("Unregister", comment: ""), image: UIImage(named: "banicon")!, callback: { self.terminate() })
        
        if !UserDefaults.standard.isTempUser {
            items.append([])
            items.append([])
            items.append([])

            let givts = Setting(name: NSLocalizedString("HistoryTitle", comment: ""), image: UIImage(named: "list")!, showBadge: GivtManager.shared.hasOfflineGifts(),callback: { self.openHistory() })
            items[0].append(givts)
            let givtsTaxOverviewAvailable: Setting?
            if UserDefaults.standard.hasGivtsInPreviousYear && !UserDefaults.standard.showCasesByUserID.contains(UserDefaults.Showcase.taxOverview.rawValue)  {
                givtsTaxOverviewAvailable = Setting(name: NSLocalizedString("YearOverviewAvailable", comment: ""), image: UIImage(), callback: {
                    self.openHistory()
                }, showArrow: false, isHighlighted: true)
                items[0].append(givtsTaxOverviewAvailable!)
            }

            let givingLimitImage = UserDefaults.standard.currencySymbol == "£" ? #imageLiteral(resourceName: "pound") : #imageLiteral(resourceName: "euro")
            items[0].append(Setting(name: NSLocalizedString("GiveLimit", comment: ""), image: givingLimitImage, callback: { self.openGiveLimit() }))
            items[0].append(changePersonalInfo)
            items[0].append(amountPresets)
            
            let accessCode = Setting(name: NSLocalizedString("Pincode", comment: ""), image: UIImage(named: "lock")!, callback: { self.pincode() })
            
            items[0].append(accessCode)
            
            if(InfraManager.biometricType() == .touch) {
                let fingerprint = Setting(name: NSLocalizedString("TouchID", comment: ""), image: #imageLiteral(resourceName: "TouchID"), callback: { self.manageFingerprint() })
                items[0].append(fingerprint)
            } else if(InfraManager.biometricType() == .face) {
                let fingerprint = Setting(name: NSLocalizedString("FaceID", comment: ""), image: #imageLiteral(resourceName: "FaceID"), callback: { self.manageFingerprint() })
                items[0].append(fingerprint)
            }
            items[1] = [changeAccount, screwAccount]
            items[2] = [appInfo, aboutGivt, shareGivt]
            
            if !LoginManager.shared.isFullyRegistered {
                items.insert([finishRegistration], at: 0)
            }
        } else {
            items =
                [
                    [finishRegistration],
                    [amountPresets],
                    [changeAccount, screwAccount],
                    [aboutGivt, shareGivt],
            ]
        }
    }
    
    private var device: AVCaptureDevice?
    private var blinkTimer: Timer = Timer()
    private func toggleTorch() {
        InfraManager.shared.flashTorch(length: 10, interval: 0.1)
    }
    
    private func changeAmountPresets() {
        let vc = UIStoryboard(name: "AmountPresets", bundle: nil).instantiateInitialViewController()
        vc!.transitioningDelegate = self.slideFromRightAnimation
        DispatchQueue.main.async {
            self.present(vc!, animated: true, completion:  nil)}
    }
    
    private func manageFingerprint() {
        let vc = UIStoryboard(name: "Fingerprint", bundle: nil).instantiateInitialViewController()
        vc!.transitioningDelegate = self.slideFromRightAnimation
        navigationManager.pushWithLogin(vc!, context: self)
    }
    
    private func changePersonalInfo() {
        let vc = UIStoryboard(name: "Personal", bundle: nil).instantiateInitialViewController()
        vc?.transitioningDelegate = self.slideFromRightAnimation
        navigationManager.pushWithLogin(vc!, context: self)
    }
    
    private func pincode() {
        let vc = UIStoryboard(name: "Pincode", bundle: nil).instantiateViewController(withIdentifier: "PinNavViewController") as! PinNavViewController
        vc.typeOfPin = .set
        vc.transitioningDelegate = self.slideFromRightAnimation
        navigationManager.pushWithLogin(vc, context: self)
    }
    
    private func terminate() {
        logService.info(message: "User is terminating account via the menu")
        let vc = UIStoryboard(name: "TerminateAccount", bundle: nil).instantiateViewController(withIdentifier: "TerminateAccountNavigationController") as! BaseNavigationController
        vc.transitioningDelegate = self.slideFromRightAnimation
        if UserDefaults.standard.isTempUser { //temp users can screw their account without authentication
            self.present(vc, animated: true, completion: {
            })
        } else {
            NavigationManager.shared.pushWithLogin(vc, context: self)
        }

    }
    
    private func about() {
        let vc = UIStoryboard(name: "AboutGivt", bundle: nil).instantiateViewController(withIdentifier: "AboutNavigationController") as! BaseNavigationController
        vc.transitioningDelegate = self.slideFromRightAnimation
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion:  {
            }
        )}
    }
    
    private func share() {
        /* https://stackoverflow.com/questions/13907156/uiactivityviewcontroller-taking-long-time-to-present */
        SVProgressHUD.show()
        logService.info(message: "App is being shared through the menu")
        let concurrentQueue = DispatchQueue(label: "openActivityIndicatorQueue", attributes: .concurrent)
        concurrentQueue.async {
            let message = NSLocalizedString("ShareGivtTextLong", comment: "")
            let url = URL(string: "https://www.givtapp.net/download")!
            let activityViewController = UIActivityViewController(activityItems: [self, message, url], applicationActivities: nil)
            activityViewController.excludedActivityTypes = [.airDrop]
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    private func register() {
        if navigationManager.hasInternetConnection(context: self) {
            navigationManager.finishRegistration(self)
        }
    }
    
    private func logout() {
        logService.info(message: "User is switching accounts via the menu")
        if navigationManager.hasInternetConnection(context: self) {
            LoginManager.shared.logout()
            navigationManager.loadMainPage()
        } else {
            navigationManager.presentAlertNoConnection(context: self)
        }
        
    }
    
    private func openHistory() {
        logService.info(message: "User is opening history")
        if GivtManager.shared.hasOfflineGifts() {
            let alert = UIAlertController(title: NSLocalizedString("OfflineGiftsTitle", comment: ""), message: NSLocalizedString("OfflineGiftsMessage", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "HistoryFlow") as! BaseNavigationController
            vc.transitioningDelegate = self.slideFromRightAnimation
            NavigationManager.shared.pushWithLogin(vc, context: self)
        }
    }
    
    private func openGiveLimit() {
        logService.info(message: "User is opening giving limit")
        let vc = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "registration") as! RegNavigationController
        vc.startPoint = .amountLimit
        vc.isRegistration = false
        vc.transitioningDelegate = self.slideFromRightAnimation
        NavigationManager.shared.pushWithLogin(vc, context: self)
    }
    
    private func appInfo() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "featureMenu") as! FeatureMenuViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
