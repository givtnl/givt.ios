//
//  RecurringDonationTurnTableCell.swift
//  ios
//
//  Created by Mike Pattyn on 14/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import Foundation

internal final class RecurringDonationTurnTableCell : UITableViewCell {
    
    @IBOutlet var date: UILabel!
    @IBOutlet var month: UILabel!
    @IBOutlet var amount: UILabel!
    
    var viewModel: RecurringDonationTurnViewModel? = nil {
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

//
//  RecurringRuleTableCell.swift
//  ios
//
//  Created by Jonas Brabant on 27/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

internal final class RecurringTestCell : UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
