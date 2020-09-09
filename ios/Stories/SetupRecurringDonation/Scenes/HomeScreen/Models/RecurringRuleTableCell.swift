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
    
    var recurringDonationId: String?
    var rowIndexPath: IndexPath?
    var viewModel: RecurringRuleViewModel? = nil {
        didSet{
            if let data = viewModel {
                switch data.collectGroupType {
                case .church:
                    logoImageView.image = UIImage(imageLiteralResourceName: "church_white")
                    logoContainerView.backgroundColor = ColorHelper.Church
                    stackViewRuleView.layer.borderColor = ColorHelper.Church.cgColor
                case .charity:
                    logoImageView.image = UIImage(imageLiteralResourceName: "stichting_white")
                    logoContainerView.backgroundColor = ColorHelper.Charity
                    stackViewRuleView.layer.borderColor = ColorHelper.Charity.cgColor
                case .campaign:
                    logoImageView.image = UIImage(imageLiteralResourceName: "actions_white")
                    logoContainerView.backgroundColor = ColorHelper.Action
                    stackViewRuleView.layer.borderColor = ColorHelper.Action.cgColor
                case .artist:
                    logoImageView.image = UIImage(imageLiteralResourceName: "artist")
                    logoContainerView.backgroundColor = ColorHelper.Artist
                    stackViewRuleView.layer.borderColor = ColorHelper.Artist.cgColor
                default:
                    break
                }
                
                nameLabel.text = data.collectGroupName
                
                var tempCronTextLabel = "SetupRecurringGiftText_7".localized + " " + data.getFrequencyFromCron() + " " + "RecurringDonationYouGive".localized
                if( UserDefaults.standard.currencySymbol == "£") {
                    tempCronTextLabel = tempCronTextLabel + " " + UserDefaults.standard.currencySymbol + String(format: "%.2f", data.amountPerTurn)
                } else {
                    tempCronTextLabel = tempCronTextLabel + " " + UserDefaults.standard.currencySymbol + " " + String(format: "%.2f", data.amountPerTurn)
                }
                cronTextLabel.text = tempCronTextLabel
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-yyyy"
                let endDate:String = formatter.string(from: data.getEndDateFromRule())
                endDateLabel.text = "RecurringDonationStops".localized.replacingOccurrences(of: "{0}", with: endDate)
                stopLabel.text = "CancelSubscription".localized
                stopLabel.textColor = ColorHelper.GivtRed
                recurringDonationId = data.id
                rowIndexPath = data.indexPath
                
                if let shouldShow = data.shouldShowNewItemMarker {
                    if (shouldShow) {
                        indicationImageView.isHidden = !shouldShow 
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        stopLabel.addGestureRecognizer(tap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stackViewRuleView.layer.borderWidth = 1
        stackViewRuleView.layer.cornerRadius = 8
        logoImageView.contentMode = .scaleAspectFill
        logoContainerView.layer.cornerRadius = 4
    }
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if let delegate = self.delegate {
            delegate.recurringRuleCancelTapped(recurringRuleCell: self)
        }
    }
    
    
}
