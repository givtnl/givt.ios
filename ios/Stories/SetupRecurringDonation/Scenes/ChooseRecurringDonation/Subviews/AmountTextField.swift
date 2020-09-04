//
//  VerySpecialUITextField.swift
//  ios
//
//  Created by Mike Pattyn on 04/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit

@IBDesignable
class AmountTextField: UIView {
    private var borderView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var amountLabel: UITextField!
    @IBOutlet weak var activeMarker: UIView!
    @IBOutlet weak var currencySign: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var currencyView: UIView!

    @IBOutlet weak var bottomBorderView: UIView!
    
    private var numberFormatter: NumberFormatter!
    var amount: Decimal {
        set {
            amountLabel.text = String(format: "%.2f", String(describing: newValue))
        }
        get {
            if let _ = numberFormatter.number(from: amountLabel.text!) {
                if let amountDouble = Decimal(string: amountLabel.text!, locale: Locale.current){
                    return amountDouble
                } else {
                    return 0
                }
            } else {
                return 0
            }
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
    
    private var HasDelimiter: Bool = false
    private var TextBeforeChange: String = ""
    private var HasDotAsDelimiter: Bool = false
    private var Delimiter: Character = ","
    
    private func commonInit() {
        let bundle = Bundle(for: AmountTextField.self)
        bundle.loadNibNamed("AmountTextField", owner: self, options: nil)
        
        shadowAndCorners()
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        amountLabel.baselineAdjustment = .alignCenters
        numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = .decimal
        
        amountLabel.addTarget(self, action: #selector(amountLabelEditingBegin(_:)), for: .editingDidBegin)
        amountLabel.addTarget(self, action: #selector(amountLabelEditingChanged(_:)), for: .editingChanged)
    }
    
    @objc func amountLabelEditingBegin(_ textField: UITextField) {
        if let amountLabelText = amountLabel.text {
            TextBeforeChange = amountLabelText
        }
    }
    
    @objc func amountLabelEditingChanged(_ textField: UITextField) {
        if var amountLabelText: String = amountLabel.text {
            if !amountLabelText.isEmpty && amountLabelText != TextBeforeChange {
                HasDelimiter = TextBeforeChange.contains(",") || TextBeforeChange.contains(".")
                if (HasDelimiter) {
                    HasDotAsDelimiter = TextBeforeChange.contains(".");
                    Delimiter = HasDotAsDelimiter ? "." : ","
                    if(amountLabelText.count(of: Delimiter) > 1) {
                        amountLabelText = TextBeforeChange
                        amountLabel.text = amountLabelText
                    }
                    if(amountLabelText.last == Delimiter && TextBeforeChange.last == Delimiter) {
                        amountLabelText = TextBeforeChange
                        amountLabel.text = amountLabelText
                    }
                    
                    let splittedAmountText = amountLabelText.components(separatedBy: String(Delimiter))
                    if(splittedAmountText.count == 2) {
                        if(splittedAmountText[1].count > 2) {
                            amountLabelText = TextBeforeChange
                            amountLabel.text = amountLabelText
                        }
                    }
                } else {
                    if(amountLabelText == "," || amountLabelText == ".") {
                        amountLabelText = "0"+amountLabelText
                        amountLabel.text = amountLabelText
                    }
                }
                TextBeforeChange = amountLabelText
            }
        }

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
        
        if let myBorder = bottomBorderView {
            bottomBorderView.removeFromSuperview()
            borderView.addSubview(myBorder)
            myBorder.leadingAnchor.constraint(equalTo: borderView.leadingAnchor).isActive = true
            myBorder.trailingAnchor.constraint(equalTo: borderView.trailingAnchor).isActive = true
            myBorder.bottomAnchor.constraint(equalTo: borderView.bottomAnchor).isActive = true
        }
        
        borderView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        borderView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        borderView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        borderView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
}
