//
//  BudgetListViewController.swift
//  ios
//
//  Created by Mike Pattyn on 09/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import SVProgressHUD
import UIKit

class BudgetListViewController: UIViewController, OverlayViewController {
    var overlaySize: CGSize? = CGSize(width: UIScreen.main.bounds.width * 0.9, height: 300.0)
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var labelGivt: UILabel!
    @IBOutlet weak var stackViewGivt: UIStackView!
    @IBOutlet weak var stackViewGivtHeight: NSLayoutConstraint!
    @IBOutlet weak var labelNotGivt: UILabel!
    @IBOutlet weak var stackViewNotGivt: UIStackView!
    @IBOutlet weak var stackViewNotGivtHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonExternal: CustomButton!
    
    var collectGroupsForCurrentMonth: [MonthlySummaryDetailModel]? = nil
    var notGivtModelsForCurrentMonth: [ExternalDonationModel]? = nil
    var monthDate: Date? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        if !SVProgressHUD.isVisible() {
            SVProgressHUD.show()
        }
        loadDonations()
    }
    
    override func viewDidLoad() {
        setupHeader()
        setupTerms()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
}

