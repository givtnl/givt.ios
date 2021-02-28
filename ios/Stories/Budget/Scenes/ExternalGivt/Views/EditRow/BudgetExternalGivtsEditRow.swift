//
//  BudgetExternalGivtsEditRow.swift
//  ios
//
//  Created by Mike Pattyn on 28/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class BudgetExternalGivtsEditRow: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
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
//        roundCorners(corners: [.allCorners], radius: 5.0)
    }
    private func commonInit() {
        let bundle = Bundle(for: BudgetExternalGivtsEditRow.self)
        bundle.loadNibNamed("BudgetExternalGivtsEditRow", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
