//
//  RecurringRuleTableCell.swift
//  ios
//
//  Created by Jonas Brabant on 27/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import Foundation
protocol RecurringRuleCancelDelegate {
    func recurringRuleCancelTapped(recurringRuleCell: RecurringRuleTableCell) -> Void
}
protocol RecurringRuleListDelegate {
    func recurringRuleListTapped(recurringRuleCell: RecurringRuleTableCell) -> Void
}

internal final class RecurringRuleTableCell : UITableViewCell {
    var cancelDelegate: RecurringRuleCancelDelegate? = nil
    var listDelegate: RecurringRuleListDelegate? = nil
    
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
    @IBOutlet weak var stopView: UIView!
    @IBOutlet weak var stopLabel: UILabel!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var listLabel: UILabel!
    
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
                
                let delimiter = NSLocale.current.decimalSeparator! as String
                if( UserDefaults.standard.currencySymbol == "£") {
                    tempCronTextLabel = tempCronTextLabel + " " + UserDefaults.standard.currencySymbol + String(format: "%.2f", data.amountPerTurn)
                } else {
                    tempCronTextLabel = tempCronTextLabel + " " + UserDefaults.standard.currencySymbol + " " + String(format: "%.2f", data.amountPerTurn)
                }
                tempCronTextLabel = tempCronTextLabel.replacingOccurrences(of: ".", with: delimiter)
                cronTextLabel.text = tempCronTextLabel
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-yyyy"
                let endDate:String = formatter.string(from: data.getEndDateFromRule())
                endDateLabel.text = "RecurringDonationStops".localized.replacingOccurrences(of: "{0}", with: endDate)
                stopLabel.text = "CancelRecurringDonation".localized
                listLabel.text = "List"
                recurringDonationId = data.id
                rowIndexPath = data.indexPath
                if let rowIndex = rowIndexPath?.row {
                    if rowIndex != 0 {
                        indicationImageView.isHidden = true
                    } else {
                        if let testShuldShow = data.shouldShowNewItemMarker {
                            if testShuldShow {
                                indicationImageView.isHidden = false
                            } else {
                                indicationImageView.isHidden = true
                            }
                        } else {
                            indicationImageView.isHidden = true
                        }
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        let stopTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleStopTap))
        stopView.addGestureRecognizer(stopTapGesture)
        let listTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleListTap))
        listView.addGestureRecognizer(listTapGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stackViewRuleView.layer.borderWidth = 1
        stackViewRuleView.layer.cornerRadius = 8
        logoImageView.contentMode = .scaleAspectFill
        logoContainerView.layer.cornerRadius = 4
    }
    @objc func handleStopTap(sender: UITapGestureRecognizer) {
        if let delegate = self.cancelDelegate {
            delegate.recurringRuleCancelTapped(recurringRuleCell: self)
        }
    }
    @objc func handleListTap(sender: UITapGestureRecognizer) {
        if let delegate = self.listDelegate {
            delegate.recurringRuleListTapped(recurringRuleCell: self)
        }
    }
}
