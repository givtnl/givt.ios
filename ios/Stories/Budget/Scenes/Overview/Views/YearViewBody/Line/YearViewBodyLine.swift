//
//  YearViewBodyLine.swift
//  ios
//
//  Created by Mike Pattyn on 07/05/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

class YearViewBodyLine: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var givenAmountView: UIView!
    @IBOutlet weak var amountLabelInside: UILabel!
    @IBOutlet weak var amountLabelOutside: UILabel!
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
        roundCorners(corners: [.topRight, .bottomRight], radius: 7)
    }
    private func commonInit() {
        let bundle = Bundle(for: YearViewBodyLine.self)
        bundle.loadNibNamed("YearViewBodyLine", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
