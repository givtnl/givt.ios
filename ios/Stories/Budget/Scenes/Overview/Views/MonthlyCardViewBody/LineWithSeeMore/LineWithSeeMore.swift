//
//  LineWithSeeMore.swift
//  ios
//
//  Created by Mike Pattyn on 27/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class LineWithSeeMore: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var seeMoreButton: UIButton!
    
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
        let bundle = Bundle(for: LineWithSeeMore.self)
        bundle.loadNibNamed("LineWithSeeMore", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        seeMoreButton.setAttributedTitle(NSMutableAttributedString(string: "BudgetSummaryShowAll".localized,
                                      attributes: [NSAttributedString.Key.underlineStyle : true]), for: .normal)
        seeMoreButton.setTitleColor(ColorHelper.SummaryLightGray, for: .normal)
    }
    @IBAction func seeMoreButton(_ sender: Any) {
        print("See more tapped")
    }
}
