//
//  LineWithIcon.swift
//  ios
//
//  Created by Mike Pattyn on 27/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class LineWithIcon: UIView {
    @IBOutlet weak var collectGroupLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet var contentView: UIView!
    var id: String?
    
    convenience init(id: String, description: String, amount: Double) {
        self.init()
        self.id = id
        self.collectGroupLabel.text = description
        self.amountLabel.text = CurrencyHelper.shared.getLocalFormat(value: amount.toFloat, decimals: true)
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
        roundCorners(corners: [.bottomLeft, .bottomRight], radius: 5.0)
    }
    
    private func commonInit() {
        let bundle = Bundle(for: LineWithIcon.self)
        bundle.loadNibNamed("LineWithIcon", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
