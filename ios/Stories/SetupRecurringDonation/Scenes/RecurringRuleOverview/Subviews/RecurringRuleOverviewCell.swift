//
//  RecurringRuleOverviewCell.swift
//  ios
//
//  Created by Jonas Brabant on 12/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable
internal final class RecurringRuleOverviewCell : UITableViewCell {
    
    @IBOutlet var Date: UILabel!
    @IBOutlet var Month: UILabel!
    @IBOutlet var Amount: UILabel!
    
    private func commonInit() {
        let bundle = Bundle(for: RecurringRuleOverviewCell.self)
        bundle.loadNibNamed("RecurringRuleOverviewCell", owner: self, options: nil)
    }
}
