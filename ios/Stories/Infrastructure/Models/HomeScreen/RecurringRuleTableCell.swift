//
//  RecurringRuleTableCell.swift
//  ios
//
//  Created by Jonas Brabant on 27/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import Foundation

internal final class RecurringRuleTableCell : UITableViewCell {
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Cron: UILabel!
    @IBOutlet weak var EndDate: UILabel!
    @IBOutlet weak var Indication: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}
