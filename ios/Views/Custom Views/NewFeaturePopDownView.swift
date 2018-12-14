//
//  NewFeaturePopDown.swift
//  ios
//
//  Created by Maarten Vergouwe on 13/12/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class NewFeaturePopDownView : UIView {
    @IBOutlet weak var label: UILabel!
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.bounds.width, height: label.bounds.height + 16)
    }
}
