//
//  BudgetExternalGivtsEditRow.swift
//  ios
//
//  Created by Mike Pattyn on 28/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class BudgetExternalGivtsEditRow: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var collectGroupLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var id: String?
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
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
//        roundCorners(corners: [.allCorners], radius: 5.0)
    }
    private func commonInit() {
        let bundle = Bundle(for: BudgetExternalGivtsEditRow.self)
        bundle.loadNibNamed("BudgetExternalGivtsEditRow", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    @IBAction func deleteButton(_ sender: Any) {
        print("Deleting \(id!)")
    }
}
