//
//  CollectGroupLabel.swift
//  ios
//
//  Created by Maarten Vergouwe on 18/08/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import UIKit

protocol CollectGroupLabelDelegate {
    func collectGroupLabelTapped() -> Void
}

@IBDesignable
class CollectGroupLabel : UIView {
    var delegate: CollectGroupLabelDelegate? = nil
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var bottomBorderView: UIView!
    @IBOutlet var label: UILabel!
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var symbolView: UIView!
    
    private var borderView: UIView!
    
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
        let bundle = Bundle(for: CollectGroupLabel.self)
        bundle.loadNibNamed("CollectGroupLabel", owner: self, options: nil)
        
        shadowAndCorners()
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        label.baselineAdjustment = .alignCenters
        label.isUserInteractionEnabled = true
        symbol.isHidden = true;
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
    
    @IBAction func labelTapped(_ sender: UITapGestureRecognizer) {
        if let delegate = self.delegate {
            delegate.collectGroupLabelTapped()
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
