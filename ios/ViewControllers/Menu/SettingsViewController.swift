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
import LGSideMenuController
import AppCenterAnalytics
import Mixpanel

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
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLogin), name: .GivtUserDidLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userViewedAnnualOverView), name: .GivtUserViewedAnnualOverview, object: nil)
    }
    
    @objc func badgeDidChange(notification:Notification) {
        //only if user is logged in
        if LoginManager.shared.isUserLoggedIn {
            DispatchQueue.main.async {
                self.loadItems()
                self.table.reloadData()
            }
        }
    }
    
    @objc func userDidLogin(notification:Notification) {
        DispatchQueue.main.async {
            self.loadItems()
            self.table.reloadData()
        }
    }
    
    @objc func userViewedAnnualOverView(notification:Notification){
        DispatchQueue.main.async {
            UserDefaults.standard.showCasesByUserID.append(UserDefaults.Showcase.taxOverview.rawValue)
            self.loadItems()
            self.table.reloadData()
        }
    }
    
    override func loadItems(){
        items = []
        let turnOnPresets = Setting(name: NSLocalizedString("AmountPresetsTitle", comment: ""), image: UIImage(named: "amountpresets")!, callback: { self.setPresets() }, showArrow: true)
        
        let changeAccount = Setting(name: NSLocalizedString("LogoffSession", comment: ""), image: UIImage(named: "exit")!, callback: { self.logout() }, showArrow: false)
        
        var appInfo: Setting? = nil
        
        if (FeatureManager.shared.features.count != 0) {
            appInfo = Setting(name: "FeatureMenuText".localized, image: #imageLiteral(resourceName: "givt_atoz"), showBadge: FeatureManager.shared.showBadge, callback: { self.appInfo() })
        }
        let aboutGivt = Setting(name: "TitleAboutGivt".localized, image: #imageLiteral(resourceName: "info24"), callback: { self.about() })
        
        let shareGivt = Setting(name: NSLocalizedString("ShareGivtText", comment: ""), image: UIImage(named: "share")!, callback: { self.share() }, showArrow: false)
        
        let finishRegistration = Setting(name: NSLocalizedString("FinalizeRegistration", comment: ""), image: #imageLiteral(resourceName: "pencil"), showBadge: true, callback: { self.register() })
        let changePersonalInfo = Setting(name: NSLocalizedString("TitlePersonalInfo", comment: ""), image: #imageLiteral(resourceName: "pencil"), showBadge: false, callback: { self.changePersonalInfo() })
        
        let screwAccount = Setting(name: NSLocalizedString("Unregister", comment: ""), image: UIImage(named: "banicon")!, callback: { self.terminate() })
        
        let setupRecurringGift = Setting(name: "MenuItem_RecurringDonation".localized, image: UIImage(named:"repeat")!, showBadge: UserDefaults.standard.toHighlightMenuList.contains( "MenuItem_RecurringDonation".localized), callback: { self.setupRecurringDonation() })
        
        let budget = Setting(name: "BudgetMenuView".localized, image: UIImage(named: "budget_menu")!, showBadge: false, callback: { self.openBudget() }, isSpecialItem: true)
        
        if !UserDefaults.standard.isTempUser {
            items.append([])
            items.append([])
            items.append([])
            items.append([])
            items.append([])
            
            items[0].append(budget)

            
            let givts = Setting(name: NSLocalizedString("HistoryTitle", comment: ""), image: UIImage(named: "list")!, showBadge: GivtManager.shared.hasOfflineGifts(),callback: { self.openHistory() })
            items[1].append(givts)
            
            if(LoginManager.shared.isFullyRegistered) {
                items[1].append(setupRecurringGift)
            }
            
            let givtsTaxOverviewAvailable: Setting?
            if UserDefaults.standard.hasGivtsInPreviousYear && !UserDefaults.standard.showCasesByUserID.contains(UserDefaults.Showcase.taxOverview.rawValue)  {
                givtsTaxOverviewAvailable = Setting(name: NSLocalizedString("YearOverviewAvailable", comment: ""), image: UIImage(), callback: {
                    self.openHistory()
                }, showArrow: false, isHighlighted: true)
                items[0].append(givtsTaxOverviewAvailable!)
            }
            
            let givingLimitImage = UserDefaults.standard.currencySymbol == "£" ? #imageLiteral(resourceName: "pound") : #imageLiteral(resourceName: "euro")
            items[1].append(Setting(name: NSLocalizedString("GiveLimit", comment: ""), image: givingLimitImage, callback: { self.openGiveLimit() }))
            items[1].append(changePersonalInfo)
            items[1].append(turnOnPresets)
            let accessCode = Setting(name: NSLocalizedString("Pincode", comment: ""), image: UIImage(named: "lock")!, callback: { self.pincode() })
            
            items[1].append(accessCode)
            
            if(InfraManager.biometricType() == .touch) {
                let fingerprint = Setting(name: NSLocalizedString("TouchID", comment: ""), image: #imageLiteral(resourceName: "TouchID"), callback: { self.manageFingerprint() })
                items[1].append(fingerprint)
            } else if(InfraManager.biometricType() == .face) {
                let fingerprint = Setting(name: NSLocalizedString("FaceID", comment: ""), image: #imageLiteral(resourceName: "FaceID"), callback: { self.manageFingerprint() })
                items[1].append(fingerprint)
            }
            items[2] = [changeAccount, screwAccount]
            if let info = appInfo {
                items[3] = [info, aboutGivt, shareGivt]
            } else {
                items[3] = [aboutGivt, shareGivt]
            }
            
            if !LoginManager.shared.isFullyRegistered {
                items.insert([finishRegistration], at: 0)
            }
        } else {            
            if let info = appInfo {
                items =
                    [
                        [finishRegistration],
                        [turnOnPresets],
                        [changeAccount, screwAccount],
                        [info, aboutGivt, shareGivt],
                ]
            } else {
                items =
                    [
                        [finishRegistration],
                        [turnOnPresets],
                        [changeAccount, screwAccount],
                        [aboutGivt, shareGivt],
                ]
            }
        }
    }
    
    private var device: AVCaptureDevice?
    private var blinkTimer: Timer = Timer()
    private func toggleTorch() {
        InfraManager.shared.flashTorch(length: 10, interval: 0.1)
    }
    
    private func openBudget() {
        DispatchQueue.main.async {
            self.hideMenuAnimated() {
                self.navigationManager.executeWithLogin(context: self) {
                    SVProgressHUD.show()
                    try! Mediater.shared.send(request: OpenSummaryRoute(fromDate: Date()), withContext: self)
                }
            }
        }
    }
    
    private func setPresets() {
        let vc = UIStoryboard(name: "Presets", bundle: nil).instantiateViewController(withIdentifier: "PresetsNavigationViewController") as! PresetsNavigationViewController
        vc.modalPresentationStyle = .fullScreen
        vc.transitioningDelegate = self.slideFromRightAnimation
        DispatchQueue.main.async {
            self.hideMenuAnimated() {
                self.present(vc, animated: true, completion:  nil)
            }
        }
    }
    
    private func changeAmountPresets() {
        let vc = UIStoryboard(name: "AmountPresets", bundle: nil).instantiateInitialViewController()
        vc?.transitioningDelegate = self.slideFromRightAnimation
        vc?.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.hideMenuAnimated() {
                self.present(vc!, animated: true, completion:  nil)
            }
        }
    }
    
    private func manageFingerprint() {
        let vc = UIStoryboard(name: "Fingerprint", bundle: nil).instantiateInitialViewController()
        vc?.transitioningDelegate = self.slideFromRightAnimation
        vc?.modalPresentationStyle = .fullScreen
        hideMenuAnimated() {
            self.navigationManager.pushWithLogin(vc!, context: self)
        }
    }
    
    private func changePersonalInfo() {
        let vc = UIStoryboard(name: "Personal", bundle: nil).instantiateInitialViewController()
        vc?.transitioningDelegate = self.slideFromRightAnimation
        vc?.modalPresentationStyle = .fullScreen
        hideMenuAnimated() {
            self.navigationManager.pushWithLogin(vc!, context: self)
        }
    }
    
    private func pincode() {
        let vc = UIStoryboard(name: "Pincode", bundle: nil).instantiateViewController(withIdentifier: "PinNavViewController") as! PinNavViewController
        vc.modalPresentationStyle = .fullScreen
        vc.typeOfPin = .set
        vc.transitioningDelegate = self.slideFromRightAnimation
        hideMenuAnimated() {
            self.navigationManager.pushWithLogin(vc, context: self)
        }
    }
    
    private func terminate() {
        logService.info(message: "User is terminating account via the menu")
        let vc = UIStoryboard(name: "TerminateAccount", bundle: nil).instantiateViewController(withIdentifier: "TerminateAccountNavigationController") as! BaseNavigationController
        vc.modalPresentationStyle = .fullScreen
        vc.transitioningDelegate = self.slideFromRightAnimation
        if UserDefaults.standard.isTempUser { //temp users can screw their account without authentication
            self.present(vc, animated: true, completion: {
            })
        } else {
            hideMenuAnimated() {
                NavigationManager.shared.pushWithLogin(vc, context: self)
            }
        }
        
    }
    
    private func about() {
        let vc = UIStoryboard(name: "AboutGivt", bundle: nil).instantiateViewController(withIdentifier: "AboutNavigationController") as! BaseNavigationController
        vc.transitioningDelegate = self.slideFromRightAnimation
        vc.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.hideMenuAnimated() {
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    private func share() {
        /* https://stackoverflow.com/questions/13907156/uiactivityviewcontroller-taking-long-time-to-present */
        hideMenuAnimated() {
            SVProgressHUD.show()
            self.logService.info(message: "App is being shared through the menu")
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
    }
    
    private func register() {
        if navigationManager.hasInternetConnection(context: self) {
            hideMenuAnimated() {
                self.navigationManager.finishRegistration(self)
            }
        }
    }
    
    private func logout() {
        logService.info(message: "User is switching accounts via the menu")
        if navigationManager.hasInternetConnection(context: self) {
            hideMenuAnimated {
                LoginManager.shared.logout()
                self.navigationManager.loadMainPage()
            }
        } else {
            navigationManager.presentAlertNoConnection(context: self)
        }
        
    }
    
    private func openHistory() {
        logService.info(message: "User is opening history")
        if GivtManager.shared.hasOfflineGifts() {
            let alert = UIAlertController(title: NSLocalizedString("OfflineGiftsTitle", comment: ""), message: NSLocalizedString("OfflineGiftsMessage", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "HistoryFlow") as! BaseNavigationController
            vc.transitioningDelegate = self.slideFromRightAnimation
            vc.modalPresentationStyle = .fullScreen
            hideMenuAnimated() {
                NavigationManager.shared.pushWithLogin(vc, context: self)
            }
        }
    }
    
    private func openGiveLimit() {
        logService.info(message: "User is opening giving limit")
        let vc = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "registration") as! RegNavigationController
        vc.startPoint = .amountLimit
        vc.isRegistration = false
        vc.transitioningDelegate = self.slideFromRightAnimation
        vc.modalPresentationStyle = .fullScreen
        hideMenuAnimated() {
            NavigationManager.shared.pushWithLogin(vc, context: self)
        }
    }
    
    private func appInfo() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "featureMenu") as! FeatureMenuViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func startFirstDestinationThenAmountFlow() {
        
        let vc = UIStoryboard(name:"FirstDestinationThenAmount", bundle: nil).instantiateInitialViewController()
        vc?.modalPresentationStyle = .fullScreen
        vc?.transitioningDelegate = self.slideFromRightAnimation
        DispatchQueue.main.async {
            self.hideMenuAnimated() {
                NavigationManager.shared.pushWithLogin(vc!, context: self)
            }
        }
    }
    
    private func setupRecurringDonation() {
        MSAnalytics.trackEvent("RECURRING_DONATIONS_MENU_CLICKED")
        Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_MENU_CLICKED")
        let vc = UIStoryboard(name:"SetupRecurringDonation", bundle: nil).instantiateInitialViewController()
        vc?.modalPresentationStyle = .fullScreen
        vc?.transitioningDelegate = self.slideFromRightAnimation
        if let index =  UserDefaults.standard.toHighlightMenuList.firstIndex(of: "MenuItem_RecurringDonation".localized) {
            UserDefaults.standard.toHighlightMenuList.remove(at: index)
        }
        NotificationCenter.default.post(name: .GivtBadgeNumberDidChange, object: nil)
        DispatchQueue.main.async {
            self.hideMenuAnimated() {
                NavigationManager.shared.pushWithLogin(vc!, context: self)
            }
        }
    }
}
