//
//  MonthlyCardViewLine.swift
//  ios
//
//  Created by Mike Pattyn on 25/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class MonthlyCardViewLine : UIView {
    @IBOutlet weak var collectGroupLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
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
        roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5.0)
    }
    convenience init(description: String, amount: Double) {
        self.init()
        collectGroupLabel.text = description
        amountLabel.text = CurrencyHelper.shared.getLocalFormat(value: amount.toFloat, decimals: true)
    }
    private func commonInit() {
        let bundle = Bundle(for: MonthlyCardViewLine.self)
        bundle.loadNibNamed("MonthlyCardViewLine", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}

extension MonthlyCardViewLine {
    static func Empty(description: String) -> MonthlyCardViewLine {
        let line = MonthlyCardViewLine()
        line.collectGroupLabel.text = description
        line.amountLabel.text = String.empty
        return line
    }
}
