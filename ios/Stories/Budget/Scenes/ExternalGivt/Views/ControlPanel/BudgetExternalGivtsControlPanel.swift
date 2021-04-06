//
//  BudgetExternalGivtsControlPanel.swift
//  ios
//
//  Created by Mike Pattyn on 27/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import UIKit

class BudgetExternalGivtsControlPanel: UIView {
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
        roundCorners(corners: [.allCorners], radius: 5.0)
    }
    private func commonInit() {
        let bundle = Bundle(for: BudgetExternalGivtsControlPanel.self)
        bundle.loadNibNamed("BudgetExternalGivtsControlPanel", owner: self, options: nil)
        self.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.9647058824, blue: 0.9725490196, alpha: 1)
    }
}
