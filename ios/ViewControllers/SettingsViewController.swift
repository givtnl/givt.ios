//
//  SettingsViewController.swift
//  ios
//
//  Created by Lennie Stockman on 10/01/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit
import SVProgressHUD

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActivityItemSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cellIdentifier = "SettingsItemTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SettingsItemTableViewCell
            let temp = self.items[indexPath.section]
            cell.settingLabel.text = temp[indexPath.row].name
            cell.settingImageView.image = temp[indexPath.row].image
            cell.badge.isHidden = temp[indexPath.row].isHidden
            cell.arrow.alpha = temp[indexPath.row].showArrow ? 1.0 : 0.0
            return cell
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
        let userInfo: String = !LoginManager.shared.isFullyRegistered ? NSLocalizedString("FinalizeRegistration", comment: "") : NSLocalizedString("TitlePersonalInfo", comment: "")
        
        let tempUser = UserDefaults.standard.tempUser
        
        let changeAccount = Setting(name: NSLocalizedString("MenuSettingsSwitchAccounts", comment: ""), image: UIImage(named: "person")!, callback: { self.logout() }, showArrow: false)
        
        let aboutGivt = Setting(name: NSLocalizedString("TitleAboutGivt", comment: ""), image: UIImage(named: "info24")!, callback: { self.about() })
        let shareGivt = Setting(name: NSLocalizedString("ShareGivtText", comment: ""), image: UIImage(named: "share")!, callback: { self.share() }, showArrow: false)
        var userInfoSetting: Setting?
        if LoginManager.shared.isFullyRegistered {
            userInfoSetting = Setting(name: userInfo, image: UIImage(named: "pencil")!, isHidden: LoginManager.shared.isFullyRegistered, callback: { self.changePersonalInfo() })
        } else {
            userInfoSetting = Setting(name: userInfo, image: UIImage(named: "pencil")!, isHidden: LoginManager.shared.isFullyRegistered, callback: { self.register() })
        }
        
        
        if !tempUser {
            let givts = Setting(name: NSLocalizedString("HistoryTitle", comment: ""), image: UIImage(named: "list")!, callback: { self.openHistory() })
            let limit = Setting(name: NSLocalizedString("GiveLimit", comment: ""), image: UIImage(named: "euro")!, callback: { self.openGiveLimit() })
            let accessCode = Setting(name: NSLocalizedString("Pincode", comment: ""), image: UIImage(named: "lock")!, callback: { self.pincode() })
            let screwAccount = Setting(name: NSLocalizedString("Unregister", comment: ""), image: UIImage(named: "exit")!, callback: { self.terminate() })
            items =
                [
                    [givts, limit, userInfoSetting!, accessCode],
                    [changeAccount, screwAccount],
                    [aboutGivt, shareGivt],
            ]
        } else {
            items =
                [
                    [userInfoSetting!],
                    [changeAccount],
                    [aboutGivt, shareGivt],
            ]
        }
        
        settingsTable.reloadData()
    }
    
    private func changePersonalInfo() {
        UserDefaults.standard.bearerToken = ""
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
        let vc = UIStoryboard(name: "TerminateAccount", bundle: nil).instantiateViewController(withIdentifier: "TerminateAccountNavigationController") as! AboutNavigationController
        vc.transitioningDelegate = self.slideFromRightAnimation
        NavigationManager.shared.pushWithLogin(vc, context: self)
    }
    
    private func about() {
        
        DispatchQueue.main.async {
            let vc = UIStoryboard(name: "AboutGivt", bundle: nil).instantiateViewController(withIdentifier: "AboutNavigationController") as! AboutNavigationController
            vc.transitioningDelegate = self.slideFromRightAnimation
            self.present(vc, animated: true, completion: {
                self.hideLeftView(self)
            })
        }
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
                self.present(activityViewController, animated: true, completion: {
                    self.hideLeftView(self)
                })
            }
        }
    }
    
    private func register() {
        navigationManager.finishRegistration(self)
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
        let vc = storyboard?.instantiateViewController(withIdentifier: "history") as! HistoryViewController
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
    
    // MARK: - Table view data source

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
