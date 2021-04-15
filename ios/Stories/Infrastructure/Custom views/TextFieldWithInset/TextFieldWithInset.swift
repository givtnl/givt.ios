//
//  TextFieldWithInset.swift
//  ios
//
//  Created by Mike Pattyn on 28/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class TextFieldWithInset: UITextField {
    private var padding: UIEdgeInsets!
    
    @IBInspectable var xInset: CGFloat = 0 {
        didSet {
            padding = UIEdgeInsets(top: 0, left: xInset, bottom: 0, right: xInset)
        }
    }

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
