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
    var context: UIViewController!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var tapGesture: UITapGestureRecognizer!
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
        if label.bounds.height + 16 >= 60 {
            return CGSize(width: self.bounds.width, height: label.bounds.height + 16)
        }
        else {
            return CGSize(width: self.bounds.width, height: 60)
        }
    }
}
