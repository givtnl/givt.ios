//
//  YearlyOverviewDetailLine.swift
//  ios
//
//  Created by Mike Pattyn on 10/06/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class YearlyOverviewDetailLine: UIView {
    var data: MonthlySummaryDetailModel? {
        didSet {
            if let model = data {
                descriptionLabel.text = model.Key
                amountLabel.text = model.Value.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
                if let deductable = model.TaxDeductable {
                    deductableLabel.isHidden = !deductable
                } else {
                    deductableLabel.isHidden = true
                }
            }
        }
    }
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var deductableLabel: UILabel!
    
    @IBOutlet var contentView: UIView!
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
    }
    
    private func commonInit() {
        let bundle = Bundle(for: YearlyOverviewDetailLine.self)
        bundle.loadNibNamed("YearlyOverviewDetailLine", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
