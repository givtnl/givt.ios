//
//  RoundedButton.swift
//  GivtApp
//
//  Created by Lennie Stockman on 01/06/2017.
//  Copyright © 2017 Lennie Stockman. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class RoundedButton: UIButton{
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.black {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderAlpha: CGFloat = 1 {
        didSet {
            if(borderAlpha > 1 || borderAlpha < 0){
                borderAlpha = 1
            }
            layer.borderColor = borderColor.withAlphaComponent(borderAlpha).cgColor
        }
    }
}
