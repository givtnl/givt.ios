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

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActivityItemSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = self.items[indexPath.section][indexPath.row]
        
        var cell: SettingsItemTableViewCell? = nil
        if setting.showArrow {
            if setting.showBadge {
                cell = tableView.dequeueReusableCell(withIdentifier: "SettingsItemBadgeAndArrow", for: indexPath) as? SettingsItemBadgeAndArrow
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "SettingsItemArrow", for: indexPath) as? SettingsItemArrow
            }
        } else {
            if setting.isHighlighted {
                cell = tableView.dequeueReusableCell(withIdentifier: "HighlightedItem", for: indexPath) as? HighlightedItem
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "SettingsItemTableViewCell", for: indexPath) as? SettingsItemTableViewCell //normal cell
            }
            
        }
    
        cell!.settingLabel.text = setting.name
        cell!.settingImageView.image = setting.image
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = self.items[indexPath.section]
        let cell = section[indexPath.row]
        cell.callback()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTable.dataSource = self
        settingsTable.delegate = self
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var settingsTable: UITableView!
    
    //new
    
    var logService: LogService = LogService.shared
    private let slideFromRightAnimation = PresentFromRight()
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType?) -> Any? {
        return ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        return NSLocalizedString("GivtGewoonBlijvenGeven", comment: "")
    }
    
    private var navigationManager = NavigationManager.shared
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
    
    var firstSection = [Setting]()
    var secondSection = [Setting]()
    
    let section = ["Normale instellingen", "Anders"]
    
    var items = [[Setting]]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSettings()
    }
    
    func loadSettings(){
        items = []
        let userInfo: String = !LoginManager.shared.isFullyRegistered ? NSLocalizedString("FinalizeRegistration", comment: "") : NSLocalizedString("TitlePersonalInfo", comment: "")
        
        let tempUser = UserDefaults.standard.isTempUser
        
        let changeAccount = Setting(name: NSLocalizedString("LogoffSession", comment: ""), image: UIImage(named: "exit")!, callback: { self.logout() }, showArrow: false)
        
        let aboutGivt = Setting(name: NSLocalizedString("TitleAboutGivt", comment: ""), image: UIImage(named: "info24")!, callback: { self.about() })
        let shareGivt = Setting(name: NSLocalizedString("ShareGivtText", comment: ""), image: UIImage(named: "share")!, callback: { self.share() }, showArrow: false)
        var userInfoSetting: Setting?
        if LoginManager.shared.isFullyRegistered {
            userInfoSetting = Setting(name: userInfo, image: UIImage(named: "pencil")!, callback: { self.changePersonalInfo() })
        } else {
            userInfoSetting = Setting(name: userInfo, image: UIImage(named: "pencil")!, showBadge: !LoginManager.shared.isFullyRegistered, callback: { self.register() })
        }
        
        let screwAccount = Setting(name: NSLocalizedString("Unregister", comment: ""), image: UIImage(named: "banicon")!, callback: { self.terminate() })
        
        if !tempUser {
            items.append([])
            items.append([])
            items.append([])
            
            let givts = Setting(name: NSLocalizedString("HistoryTitle", comment: ""), image: UIImage(named: "list")!, callback: { self.openHistory() })
            items[0].append(givts)
            let givtsTaxOverviewAvailable: Setting?
            if UserDefaults.standard.hasGivtsInPreviousYear && !UserDefaults.standard.showCasesByUserID.contains(UserDefaults.Showcase.taxOverview.rawValue)  {
                givtsTaxOverviewAvailable = Setting(name: NSLocalizedString("YearOverviewAvailable", comment: ""), image: UIImage(), callback: {
                    self.openHistory()
                }, showArrow: false, isHighlighted: true)
                items[0].append(givtsTaxOverviewAvailable!)
            }
            
            
            let limit = Setting(name: NSLocalizedString("GiveLimit", comment: ""), image: UIImage(named: "euro")!, callback: { self.openGiveLimit() })
            items[0].append(limit)
            items[0].append(userInfoSetting!)
            
            let accessCode = Setting(name: NSLocalizedString("Pincode", comment: ""), image: UIImage(named: "lock")!, callback: { self.pincode() })
            
            items[0].append(accessCode)
            items[1] = [changeAccount, screwAccount]
            items[2] = [aboutGivt, shareGivt]
        } else {
            items =
                [
                    [userInfoSetting!],
                    [changeAccount, screwAccount],
                    [aboutGivt, shareGivt],
            ]
        }
        
        settingsTable.reloadData()
    }
    
    private var device: AVCaptureDevice?
    private var blinkTimer: Timer = Timer()
    private func toggleTorch() {
        InfraManager.shared.flashTorch(length: 10, interval: 0.1)
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
        if AppServices.shared.connectedToNetwork() {
            navigationManager.finishRegistration(self)
        } else {
            let noInternetAlert = UIAlertController(title: NSLocalizedString("NoInternetConnectionTitle", comment: ""), message: NSLocalizedString("NoInternet", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            noInternetAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                
            }))
            self.present(noInternetAlert, animated: true, completion: nil)
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
        let vc = storyboard?.instantiateViewController(withIdentifier: "HistoryFlow") as! BaseNavigationController
        vc.transitioningDelegate = self.slideFromRightAnimation
        NavigationManager.shared.pushWithLogin(vc, context: self)
    }
    
    private func openGiveLimit() {
        logService.info(message: "User is opening giving limit")
        let vc = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "registration") as! RegNavigationController
        vc.startPoint = .amountLimit
        vc.isRegistration = false
        vc.transitioningDelegate = self.slideFromRightAnimation
        NavigationManager.shared.pushWithLogin(vc, context: self)
    }
}
