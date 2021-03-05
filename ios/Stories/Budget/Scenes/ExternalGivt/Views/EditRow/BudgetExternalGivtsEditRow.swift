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
    var guid: String?
    var objectId: NSManagedObjectID?
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    convenience init(objectId: NSManagedObjectID, guid: String, name: String, amount: Double) {
        self.init()
        self.objectId = objectId
        self.guid = guid
        self.collectGroupLabel.text = name
        self.amountLabel.text = amount.getFormattedWith(currency: UserDefaults.standard.currencySymbol, decimals: 2)
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
        print("Deleting \(guid!)")
    }
}
