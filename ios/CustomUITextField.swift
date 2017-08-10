//
//  CustomUITextField.swift
//  ios
//
//  Created by Lennie Stockman on 09/08/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation
import UIKit

class CustomUITextField: UITextField{
    override func awakeFromNib() {
        self.layer.borderColor = UIColor.init(red: 234, green: 234, blue: 238).cgColor
        self.layer.borderWidth = 1.0
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
    
    
}
