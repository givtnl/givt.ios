//
//  RecurringRuleOverviewCell.swift
//  ios
//
//  Created by Jonas Brabant on 12/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import Foundation

internal final class RecurringRuleOverviewTableCell : UITableViewCell {
    
    @IBOutlet var date: UILabel!
    @IBOutlet var month: UILabel!
    @IBOutlet var amount: UILabel!
    
    var viewModel: RecurringDonationDonationViewModel? = nil {
        didSet{
            if let data = viewModel {
                self.date.text = "blablbabla"
                self.month.text = "blablabla"
                self.amount.text = "15"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}
