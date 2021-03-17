//
//  CardViewBody.swift
//  ios
//
//  Created by Mike Pattyn on 18/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import UIKit

class MonthlyCardViewBody: UIView {
    private var borderView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var labelGivt: UILabel!
    
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
    
    private func commonInit() {
        let bundle = Bundle(for: MonthlyCardViewBody.self)
        bundle.loadNibNamed("MonthlyCardViewBody", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
