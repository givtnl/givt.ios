//
//  RecurringRuleTableCell.swift
//  ios
//
//  Created by Jonas Brabant on 27/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import Foundation

protocol RecurringRuleTableCellDelegate {
    func recurringRuleTableCellTapped() -> Void
}

internal final class RecurringRuleTableCell : UITableViewCell {
    var delegate: RecurringRuleTableCellDelegate? = nil

    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Cron: UILabel!
    @IBOutlet weak var EndDate: UILabel!
    @IBOutlet weak var Indication: UIImageView!
    @IBOutlet weak var CenterView: UIView!
    @IBOutlet weak var Logo: UIImageView!
    @IBOutlet weak var LogoView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.insetBy(dx: 0, dy: 5)
        CenterView.layer.borderWidth = 1
        CenterView.layer.cornerRadius = 8
        Indication.isHidden = true
        Logo.contentMode = .scaleAspectFill
        LogoView.layer.cornerRadius = 4
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if let delegate = self.delegate {
            delegate.recurringRuleTableCellTapped()
       }
    }
}
