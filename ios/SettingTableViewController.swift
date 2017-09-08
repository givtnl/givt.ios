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
        loadSettings()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    private func loadSettings(){
        // key: "Next", comment: "Next button"
        let givts = Setting(name: NSLocalizedString("HistoryTitle", comment: ""), image: UIImage(named: "list")!, callback: {})
        
        let limit = Setting(name: NSLocalizedString("GiveLimit", comment: ""), image: UIImage(named: "euro")!, callback: { self.openGiveLimit() })
        let accessCode = Setting(name: NSLocalizedString("Pincode", comment: ""), image: UIImage(named: "lock")!, callback: {})
        
        let changeAccount = Setting(name: NSLocalizedString("MenuSettingsSwitchAccounts", comment: ""), image: UIImage(named: "person")!, callback: {})
        let screwAccount = Setting(name: NSLocalizedString("Unregister", comment: ""), image: UIImage(named: "exit")!, callback: {})
        
        let aboutGivt = Setting(name: NSLocalizedString("TitleAboutGivt", comment: ""), image: UIImage(named: "info24")!, callback: {})

        let shareGivt = Setting(name: NSLocalizedString("ShareGivtText", comment: ""), image: UIImage(named: "share")!, callback: {})
        
        items +=
            [
                [givts, limit, accessCode],
                [changeAccount, screwAccount],
                [aboutGivt, shareGivt]
            ]
    }
    
    private func openGiveLimit() {
        if !LoginManager().isBearerStillValid {
            let loginVC = storyboard?.instantiateViewController(withIdentifier: "lvc") as! LoginViewController
            let completionHandler:(LoginViewController)->Void = { test in
                let amountLimitVC = self.storyboard?.instantiateViewController(withIdentifier: "alvc") as! AmountLimitViewController
                DispatchQueue.main.async {
                    self.present(amountLimitVC, animated: true, completion: nil)
                }
            }
            loginVC.completionHandler = completionHandler
            self.present(loginVC, animated: true, completion: nil)
        } else {
            let amountLimitVC = storyboard?.instantiateViewController(withIdentifier: "alvc") as! AmountLimitViewController
            // self.present(amountLimitVC, animated: true)
            self.present(amountLimitVC, animated: true)
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
        print(temp[indexPath.row].callback)
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
