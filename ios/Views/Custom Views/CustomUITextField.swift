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
    override func awakeFromNib() {
        self.layer.borderColor = self.originalColor.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 4
        self.backgroundColor = .white
        self.setLeftPaddingPoints(15)
        self.setRightPaddingPoints(15)
    }
    private var border: CALayer = CALayer()
    var isValid = false {
        didSet {
            if isValid {
                self.layer.borderColor = #colorLiteral(red: 0.1098039216, green: 0.662745098, blue: 0.4235294118, alpha: 1)
            } else {
                self.layer.borderColor = #colorLiteral(red: 0.7372586131, green: 0.09625744075, blue: 0.1143460795, alpha: 1)
            }
        }
    }
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
