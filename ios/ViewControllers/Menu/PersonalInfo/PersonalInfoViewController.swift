//
//  PersonalInfoViewController.swift
//  ios
//
//  Created by Lennie Stockman on 30/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit
import SVProgressHUD

class PersonalInfoViewController: UIViewController, UITextFieldDelegate {
    var settings: [UserInfoRowDetail]!
    var uExt: LMUserExt?
    
    private var position: Int?
    private var deleting: Bool = false
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet var titleText: UILabel!
    @IBOutlet var settingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadSettings() { settings in
            self.settings = settings
            self.settingsTableView.reloadData()
            SVProgressHUD.dismiss()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let selectedRow = settingsTableView.indexPathForSelectedRow {
            settingsTableView.deselectRow(at: selectedRow, animated: false)
        }
    }
}
