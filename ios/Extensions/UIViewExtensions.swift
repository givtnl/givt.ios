//
//  UIView.swift
//  ios
//
//  Created by Mike Pattyn on 17/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import UIKit

extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func setBorderColor(_ color: UIColor) {
        self.layer.borderColor = color.cgColor
    }
    func resetBorderColor(_ color: UIColor = UIColor.init(red: 234, green: 234, blue: 238)) {
        self.layer.borderColor = color.cgColor
    }
    
    func setBorders(_ isValid: Bool?) {
        if let isValid = isValid {
            isValid ? setValid() : setInvalid()
            return
        } else {
            resetBorderColor()
            return
        }
    }
    
    @objc func setValid(){
        setBorderColor(#colorLiteral(red: 0.2549019608, green: 0.7882352941, blue: 0.5568627451, alpha: 1))
    }
    @objc func setInvalid(){
        setBorderColor(#colorLiteral(red: 0.8439754844, green: 0.2364770174, blue: 0.2862294316, alpha: 1))
    }
}
