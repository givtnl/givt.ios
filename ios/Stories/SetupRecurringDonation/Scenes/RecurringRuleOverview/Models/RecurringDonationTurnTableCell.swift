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
    @IBOutlet var giftAided: UIImageView!
    @IBOutlet var status: UIView!
    
    var overlayOn: Bool = false {
        didSet {
            self.opaqueLayer.isHidden = !self.overlayOn
        }
    }
    
    var isGiftAided: Bool = false {
        didSet {
            self.giftAided.isHidden = !self.isGiftAided
        }
    }
    
    var viewModel: RecurringDonationTurnViewModel? = nil {
        didSet{
            if let data = viewModel {
                let decimalString = "\(data.amount)"
                let doubleAmount: Double = Double(decimalString)!
                let delimiter: String = NSLocale.current.decimalSeparator!
                let currencySign = UserDefaults.standard.currencySymbol
                if currencySign == "€" {
                    currencySign += " "
                }
                amount.text = "\(currencySign)\(String(format: "%\(delimiter)2f", doubleAmount))"

                date.text = data.day
                month.text = data.month
                overlayOn = data.toBePlanned
                isGiftAided = data.isGiftAided!
                
                
                status.backgroundColor = determineColorForStatus(status: data.status)
            }
        }
    }
    private func determineColorForStatus(status: Int) -> UIColor {
        var color = UIColor.clear
        switch status {
        case 3:
            color = ColorHelper.GivtLightGreen
        case 4:
            color = ColorHelper.GivtRed
        case 5:
            color = UIColor.gray
        default:
            color = ColorHelper.GivtPurple
        }
        return color
    }
 
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        isGiftAided = false
        overlayOn = false
    }
}
