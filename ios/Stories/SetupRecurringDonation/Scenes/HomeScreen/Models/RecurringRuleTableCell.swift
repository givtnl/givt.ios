//
//  RecurringRuleTableCell.swift
//  ios
//
//  Created by Jonas Brabant on 27/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import Foundation
protocol RecurringRuleCencelDelegate {
    func recurringRuleCancelTapped(recurringRuleCell: RecurringRuleTableCell) -> Void
}

internal final class RecurringRuleTableCell : UITableViewCell {
    var delegate: RecurringRuleCencelDelegate? = nil

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cronTextLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var indicationImageView: UIImageView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var logoContainerView: UIView!
    
    @IBOutlet weak var ruleStackView: UIStackView!
    
    @IBOutlet weak var horiStackView: UIStackView!
    @IBOutlet weak var stackViewRuleView: UIView!
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var stopLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        stopLabel.addGestureRecognizer(tap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.insetBy(dx: 0, dy: 5)
        stackViewRuleView.layer.borderWidth = 1
        stackViewRuleView.layer.cornerRadius = 8
        indicationImageView.isHidden = true
        logoImageView.contentMode = .scaleAspectFill
        logoContainerView.layer.cornerRadius = 4
    }
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if let delegate = self.delegate {
            delegate.recurringRuleCancelTapped(recurringRuleCell: self)
       }
    }
}
