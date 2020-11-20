//
//  RecurringCustomUITextField.swift
//  ios
//
//  Created by Mike Pattyn on 10/11/2020.
//  Copyright © 2020 Givt. All rights reserved.
//
import Foundation
import UIKit

@IBDesignable
class RecurringCustomUITextField: UITextField{
    
    private var borderView: UIView!
    @IBOutlet var contentView: UIView!
    
    private var border: CALayer = CALayer()
    
    func isDifferentFrom(from: String) -> Bool {
        return self.text! != from
    }
    
    func beganEditing() {
        self.layer.isHidden = false
    }
    
    func endedEditing() {
        self.layer.isHidden = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        shadowAndCorners()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        shadowAndCorners()
    }
    override func awakeFromNib() {
        self.setLeftPaddingPoints(15)
        self.setRightPaddingPoints(15)
    }
    private func commonInit() {
        let bundle = Bundle(for: RecurringCustomUITextField.self)
        bundle.loadNibNamed("RecurringCustomUITextField", owner: self, options: nil)
        
        shadowAndCorners()
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    var isOccurrencesLabel: Bool = false {
        didSet {
            self.setLeftPaddingPoints(5)
            self.setRightPaddingPoints(5)
        }
    }
    
    private func shadowAndCorners() {
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
    
    func handleInputValidation(invalid: Bool) {
        if invalid {
            borderView.layer.borderColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            borderView.layer.borderWidth = 2
        } else {
            borderView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            borderView.layer.borderWidth = 1
        }
    }
}
