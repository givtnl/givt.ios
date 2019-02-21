//
//  PresetButton.swift
//  ios
//
//  Created by Mike Pattyn on 21/02/2019.
//  Copyright © 2019 Givt. All rights reserved.
//

import UIKit

@IBDesignable
class PresetButton : UIControl {
    @IBOutlet var contentView: UIButton!
    @IBOutlet var currency: UILabel!
    @IBOutlet var amount: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    @IBAction func viewTouch(_ sender: Any) {
        sendActions(for: .touchUpInside)
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    private func commonInit() {
        Bundle.main.loadNibNamed("PresetButton", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
