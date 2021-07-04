//
//  YearlyOverviewMonthlyBar.swift
//  ios
//
//  Created by Mike Pattyn on 03/07/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class YearlyOverviewMonthlyBar: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet weak var monthLabelWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet var barView: UIView!
    @IBOutlet var givtAmountView: UIView!
    @IBOutlet var notGivtAmountView: UIView!
    
    @IBOutlet var totalAmountLabel: UILabel!
    @IBOutlet var totalAmountLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet var givtAmountWidthConstraint: NSLayoutConstraint!
    @IBOutlet var notGivtAmountWidthConstraint: NSLayoutConstraint!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.allCorners], radius: 5.0)
    }
    
    private func commonInit() {
        let bundle = Bundle(for: YearlyOverviewMonthlyBar.self)
        bundle.loadNibNamed("YearlyOverviewMonthlyBar", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    var monthlyBarViewModel: MonthlyBarViewModel? = nil {
        didSet {
            if let model = monthlyBarViewModel {
                // dedecucting label widths
                let barReferenceWidth = model.maxBarWidth - monthLabelWidthConstraint.constant - totalAmountLabelWidthConstraint.constant
                
                givtAmountWidthConstraint.constant = barReferenceWidth * (model.givtAmount / model.highestAmount)
                notGivtAmountWidthConstraint.constant = barReferenceWidth * (model.notGivtAmount / model.highestAmount)
                monthLabel.text = model.date.getMonthName()
                totalAmountLabel.text = (model.givtAmount + model.notGivtAmount).getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
            }
        }
    }
}
