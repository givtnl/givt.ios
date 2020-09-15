//
//  CollecteView.swift
//  ios
//
//  Created by Mike Pattyn on 18/02/2019.
//  Copyright © 2019 Givt. All rights reserved.
//

import UIKit

@IBDesignable
class CollectionView: UIControl {
    private var borderView: UIView!
    @IBOutlet var contentView: UIControl!
    @IBOutlet var collectLabel: UILabel!
    @IBOutlet var deleteBtn: UIButton!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var currencySign: UILabel!
    @IBOutlet weak var activeMarker: UIView!
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CollectionView", owner: self, options: nil)
        shadowAndCorners()
        styleDeleteButton()
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectLabel.adjustsFontSizeToFitWidth = true
        collectLabel.baselineAdjustment = .alignCenters
        amountLabel.baselineAdjustment = .alignCenters
        amount = "0"
    }
    
    private var _isActive: Bool = false
    
    var isActive: Bool {
        get {
            return _isActive
        }
        set {
            _isActive = newValue
            if(_isActive){
                activeMarker.isHidden = false
                if(_isValid){
                    activeMarker.backgroundColor = #colorLiteral(red: 0.2549019608, green: 0.7882352941, blue: 0.5529411765, alpha: 1)
                } else {
                    activeMarker.backgroundColor = #colorLiteral(red: 0.737254902, green: 0.09803921569, blue: 0.1137254902, alpha: 1)
                }
            } else {
                activeMarker.isHidden = true
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
    
    @IBAction func contentViewTouch(_ sender: Any) {
        sendActions(for: .touchUpInside)
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
    
    func styleDeleteButton() {
        deleteBtn.isHidden = true
        deleteBtn.setImage(#imageLiteral(resourceName: "decrease"), for: UIControlState.normal)
        deleteBtn.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        deleteBtn.translatesAutoresizingMaskIntoConstraints = false
        deleteBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        deleteBtn.contentMode = UIViewContentMode.scaleAspectFit
        deleteBtn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        deleteBtn.translatesAutoresizingMaskIntoConstraints = false
        deleteBtn.alpha = 0.5
    }
}
