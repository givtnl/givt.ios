//
//  BaseMenuViewController.swift
//  ios
//
//  Created by Maarten Vergouwe on 19/12/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
import UIKit

class BaseMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActivityItemSource {
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    var items = [[Setting]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navItem.titleView = UIImageView(image: UIImage(named: "givt20h"))
        
        /* some how we're not able to set the table first cel right below the navigation bar
         * there is a hidden table header somewhere.
         * I haven't found where to change this so, we change the contentinset to -30 */
        table.tableHeaderView = nil
        table.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0)
        table.dataSource = self
        table.delegate = self
        
        loadItems()
    }
    
    func loadItems() {
        preconditionFailure("This is an abstract function and should be overridden")
    }
    
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
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType?) -> Any? {
        return ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        return NSLocalizedString("GivtGewoonBlijvenGeven", comment: "")
    }
}

