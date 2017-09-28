//
//  CustomUITextField.swift
//  ios
//
//  Created by Lennie Stockman on 09/08/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CustomUITextField: UITextField{
    private var originalColor: UIColor = UIColor.init(red: 234, green: 234, blue: 238)
    override func awakeFromNib() {
        self.layer.borderColor = originalColor.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 4
        self.setLeftPaddingPoints(15)
        self.setRightPaddingPoints(15)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
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
    
    
}
