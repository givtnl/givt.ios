//
//  VerySpecialUITextField.swift
//  ios
//
//  Created by Mike Pattyn on 04/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit

@IBDesignable
class VerySpecialUITextField: UIView {
    private var borderView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var amountLabel: UITextField!
    @IBOutlet weak var activeMarker: UIView!
    @IBOutlet weak var currencySign: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var currencyView: UIView!

    @IBOutlet weak var bottomBorderView: UIView!
    
    var isPreset: Bool = true;
    
    var amount = "0" {
        didSet {
            amountLabel.text = amount
        }
    }
    
    var currency = "€" {
        didSet {
            currencySign.text = currency
        }
    }
    
    var isEditable = true {
        didSet {
            amountLabel.isEnabled = false
        }
    }
    
    var isValutaField = true {
        didSet {
            stackView.removeArrangedSubview(currencyView)
        }
    }
    
    @IBInspectable
    var bottomBorderColor: UIColor {
        set {
            bottomBorderView.backgroundColor = newValue
        }
        get {
            if let borderColor = bottomBorderView.backgroundColor {
                return borderColor
            } else {
                return .clear
            }
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
    
    private func commonInit() {
        let bundle = Bundle(for: VerySpecialUITextField.self)
        bundle.loadNibNamed("VerySpecialUITextField", owner: self, options: nil)
        
        shadowAndCorners()
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        amountLabel.baselineAdjustment = .alignCenters
        amount = "0"
    }
    
    private var _isValid: Bool = true
    
    var isValid: Bool {
        get {
            return _isValid
        }
        set {
            _isValid = newValue
        }
    }
    
    func shadowAndCorners() {
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.5).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 2
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        self.backgroundColor = UIColor.clear

        borderView = UIView()
        borderView.isUserInteractionEnabled = false
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = UIColor.white
        borderView.frame = self.bounds
        borderView.layer.cornerRadius = 4
        borderView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        borderView.layer.borderWidth = 1
        borderView.layer.masksToBounds = true
        self.addSubview(borderView)
        borderView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        borderView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        borderView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        borderView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

    }
}
