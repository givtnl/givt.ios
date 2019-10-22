//
//  UITextField+helpers.swift
//  ios
//
//  Created by Lennie Stockman on 27/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation
import UIKit

private var kAssociationKeyMaxLength: Int = 0

extension UITextField {
    @IBInspectable var originalColor: UIColor {
        get {
            return UIColor.init(red: 234, green: 234, blue: 238)
        }
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        paddingView.isUserInteractionEnabled = false
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        paddingView.isUserInteractionEnabled = false
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    func setBorderColor(_ color: UIColor) {
        self.layer.borderColor = color.cgColor
    }
    func resetBorderColor() {
        self.layer.borderColor = originalColor.cgColor
    }
    func setValid(){
        setBorderColor(#colorLiteral(red: 0.2549019608, green: 0.7882352941, blue: 0.5568627451, alpha: 1))
        self.returnKeyType = .done
        self.reloadInputViews()
    }
    func setInvalid(){
        setBorderColor(#colorLiteral(red: 0.8439754844, green: 0.2364770174, blue: 0.2862294316, alpha: 1))
        self.returnKeyType = .default
        self.reloadInputViews()
    }
    func setState(b: Bool) {
        b ? setValid() : setInvalid()
    }
}

class SpecialUITextField: UITextField {
    private var border: CALayer = CALayer()
    var isValid = false {
        didSet {
            if isValid {
                border.borderColor = #colorLiteral(red: 0.1098039216, green: 0.662745098, blue: 0.4235294118, alpha: 1)
            } else {
                border.borderColor = #colorLiteral(red: 0.7372586131, green: 0.09625744075, blue: 0.1143460795, alpha: 1)
            }
        }
    }
    func isDifferentFrom(from: String) -> Bool {
        return self.text! != from
    }
    func beganEditing() {
        border.isHidden = false
    }
    
    func endedEditing() {
        border.isHidden = false
    }

    override func awakeFromNib() {
        setBottomBorder()
        border.isHidden = false
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    func disable() {
        self.isEnabled = false
        border.removeFromSuperlayer()
    }
    func setBottomBorder() {
        border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
