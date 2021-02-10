//
//  BudgetViewController.swift
//  ios
//
//  Created by Mike Pattyn on 09/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class BudgetViewController : UIViewController {
    @IBOutlet weak var monthlySummaryTile: MonthlySummary!
    @IBOutlet weak var giveNowButton: GiveNowButton!
    
    override func viewDidLoad() {
        monthlySummaryTile.amountLabel.text = "€5"
        monthlySummaryTile.descriptionLabel.text = "deze maand gegeven"
        giveNowButton.buttonLabel.text = "ik wil nu geven!"
    }
}
