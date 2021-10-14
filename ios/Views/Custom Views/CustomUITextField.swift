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
