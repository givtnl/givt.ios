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
    @IBOutlet var opaqueLayer: UIView!
    
    var overlayOn: Bool = false {
        didSet {
            self.opaqueLayer.isHidden = !self.overlayOn
        }
    }
    
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
