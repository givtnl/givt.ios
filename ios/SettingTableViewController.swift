//
//  SettingTableViewController.swift
//  ios
//
//  Created by Lennie Stockman on 12/07/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import LGSideMenuController

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var lblSettings: UILabel!
    private var navigationManager = NavigationManager.shared
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
    
    var firstSection = [Setting]()
    var secondSection = [Setting]()
    
    let section = ["Normale instellingen", "Anders"]
    
    var items = [[Setting]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        lblSettings.text = NSLocalizedString("Settings", comment: "Settings")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSettings()
    }
    
    private func loadSettings(){
        let userInfo: String = !LoginManager.shared.isFullyRegistered ? NSLocalizedString("FinalizeRegistration", comment: "") : NSLocalizedString("TitlePersonalInfo", comment: "")

        let givts = Setting(name: NSLocalizedString("HistoryTitle", comment: ""), image: UIImage(named: "list")!, callback: { self.openHistory() })
        let limit = Setting(name: NSLocalizedString("GiveLimit", comment: ""), image: UIImage(named: "euro")!, callback: { self.openGiveLimit() })
        let accessCode = Setting(name: NSLocalizedString("Pincode", comment: ""), image: UIImage(named: "lock")!, callback: {})
        let changeAccount = Setting(name: NSLocalizedString("MenuSettingsSwitchAccounts", comment: ""), image: UIImage(named: "person")!, callback: { self.logout() })
        let screwAccount = Setting(name: NSLocalizedString("Unregister", comment: ""), image: UIImage(named: "exit")!, callback: {})
        let aboutGivt = Setting(name: NSLocalizedString("TitleAboutGivt", comment: ""), image: UIImage(named: "info24")!, callback: {})
        let shareGivt = Setting(name: NSLocalizedString("ShareGivtText", comment: ""), image: UIImage(named: "share")!, callback: {})
        let userInfoSetting = Setting(name: userInfo, image: UIImage(named: "pencil")!, isHidden: LoginManager.shared.isFullyRegistered, callback: { self.register() })

        items =
            [
                [givts, limit, userInfoSetting, accessCode],
                [changeAccount, screwAccount],
                [aboutGivt, shareGivt],
            ]
        self.tableView.reloadData()
    }

    
    private func register() {
        navigationManager.finishRegistration(self)
    }
    
    private func logout() {
        LoginManager.shared.logout()
        self.hideLeftView(nil)
        UIApplication.shared.keyWindow?.rootViewController?.viewDidAppear(false)
        
    }
    
    private func openHistory() {
        if !LoginManager.shared.isBearerStillValid {
            let loginVC = storyboard?.instantiateViewController(withIdentifier: "ncLogin") as! LoginNavigationViewController
            let completionHandler:()->Void = { test in
                let historyVC = self.storyboard?.instantiateViewController(withIdentifier: "history") as! HistoryViewController
                DispatchQueue.main.async {
                    
                    self.present(historyVC, animated: true, completion: nil)
                }
            }
            loginVC.outerHandler = completionHandler
            self.present(loginVC, animated: true, completion: nil)
        } else {
            let historyVC = storyboard?.instantiateViewController(withIdentifier: "history") as! HistoryViewController
            // self.present(amountLimitVC, animated: true)
            self.present(historyVC, animated: true)
        }
    }
    
    private func openGiveLimit() {
        if !LoginManager.shared.isBearerStillValid {
            let loginVC = storyboard?.instantiateViewController(withIdentifier: "ncLogin") as! LoginNavigationViewController
            let completionHandler:()->Void = { _ in
                let amountLimitVC = self.storyboard?.instantiateViewController(withIdentifier: "ncAmountLimit")
                DispatchQueue.main.async {
//                    let vc = (UIApplication.shared.delegate as! AppDelegate).window!.rootViewController as! AmountViewController
//                    let nav = vc.rootViewController as! CustomViewController
//                    nav.show(amountLimitVC, sender: nil)
                    print("ik kom er in")
                    self.navigationController?.hideLeftViewAnimated(nil)
                    self.present(amountLimitVC!, animated: true, completion: nil)
                    
                }
            }
            loginVC.outerHandler = completionHandler
            self.present(loginVC, animated: true, completion: nil)
        } else {
            let amountLimitVC = storyboard?.instantiateViewController(withIdentifier: "ncAmountLimit")
            // self.present(amountLimitVC, animated: true)
            /*
            let del = UIApplication.shared.delegate as! AppDelegate
            let vc = del.window!.rootViewController as! AmountViewController
            let nav = vc.rootViewController as! CustomViewController
            nav.pushViewController(amountLimitVC, animated: false)
            vc.hideLeftViewAnimated()
             */
            self.present(amountLimitVC!, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.items.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.items[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SettingsItemTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SettingsItemTableViewCell
        let temp = self.items[indexPath.section]
        cell.settingLabel.text = temp[indexPath.row].name
        cell.settingImageView.image = temp[indexPath.row].image
        cell.badge.isHidden = temp[indexPath.row].isHidden
        return cell
    }
    
    func finishedModalView() {
        let amountLimitVC = storyboard?.instantiateViewController(withIdentifier: "alvc") as! AmountLimitViewController
        // self.present(amountLimitVC, animated: true)
        self.present(amountLimitVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = self.items[indexPath.section]
        let cell = section[indexPath.row]
        cell.callback()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
   

}
