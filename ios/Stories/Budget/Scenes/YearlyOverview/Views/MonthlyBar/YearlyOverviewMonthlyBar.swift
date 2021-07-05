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
                let barReferenceWidth: CGFloat = CGFloat(model.maxBarWidth) - monthLabelWidthConstraint.constant - totalAmountLabelWidthConstraint.constant
                let givtAmountWidth = barReferenceWidth * CGFloat(model.givtAmount / model.highestAmount)
                let notGivtAmountWidth = barReferenceWidth * CGFloat(model.notGivtAmount / model.highestAmount)
                givtAmountWidthConstraint.constant = givtAmountWidth > 0 ? givtAmountWidth : 0
                notGivtAmountWidthConstraint.constant = notGivtAmountWidth > 0 ? notGivtAmountWidth : 0
                monthLabel.text = getMonthString(model.date!)
                totalAmountLabel.text = (model.givtAmount + model.notGivtAmount).getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
            }
        }
    }
    
    private func getMonthString(_ value: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: value).replacingOccurrences(of: ".", with: String.empty)
    }
}
