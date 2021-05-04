//
//  BudgetGivingGoalViewController.swift
//  ios
//
//  Created by Mike Pattyn on 04/05/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class BudgetGivingGoalViewController: UIViewController {
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var buttonSave: CustomButton!
    
    @IBOutlet weak var amountTitelLabel: UILabel!
    @IBOutlet weak var amountView: BudgetExternalGivtsViewWithBorder!
    @IBOutlet weak var amountViewLabelCurrency: UILabel!
    
    @IBOutlet weak var periodTitelLabel: UILabel!
    @IBOutlet weak var periodView: CustomButton!
    @IBOutlet weak var periodViewLabelDown: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !SVProgressHUD.isVisible() {
            SVProgressHUD.show()
        }
        setupTerms()
        setupUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }

}
