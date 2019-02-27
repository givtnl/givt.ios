//
//  BorderedView.swift
//  ios
//
//  Created by Mike Pattyn on 21/02/2019.
//  Copyright © 2019 Givt. All rights reserved.
//

import UIKit

@IBDesignable
class AddCollectButtonView: UIButton {
    private var borderLayer: CAShapeLayer!
    private var lineDashPattern: [NSNumber] = [0,0]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    @IBAction func viewTouch(_ sender: Any) {
        sendActions(for: .touchUpInside)
    }
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
            borderLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: newValue).cgPath
        }
    }
    
    @IBInspectable var lineWidth: CGFloat {
        get {
            return borderLayer.lineWidth
        }
        set {
            borderLayer.lineWidth = newValue
        }
    }
    @IBInspectable var strokeColor: UIColor? {
        get {
            if let color = borderLayer.strokeColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                borderLayer.strokeColor = color.cgColor
            } else {
                borderLayer.strokeColor = nil
            }
        }
    }
  
    @IBInspectable var lineDash: Int {
        get {
            if let dashPattern = borderLayer.lineDashPattern {
                return Int(truncating: dashPattern[0])
            } else {
                return 0
            }
        }
        set {
            if var dashPattern = borderLayer.lineDashPattern {
                dashPattern[0] = NSNumber(value: newValue)
                borderLayer.lineDashPattern = dashPattern
            }
        }
    }
    @IBInspectable var lineGap: Int {
        get {
            if let dashPattern = borderLayer.lineDashPattern {
                return Int(truncating: dashPattern[1])
            } else {
                return 0
            }
        }
        set {
            if var dashPattern = borderLayer.lineDashPattern {
                dashPattern[1] = NSNumber(value: newValue)
                borderLayer.lineDashPattern = dashPattern
            }
        }
    }
    
    func commonInit(){
        borderLayer =  CAShapeLayer()
        borderLayer.lineDashPattern = lineDashPattern
        borderLayer.frame = bounds
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.backgroundColor = UIColor.clear.cgColor
        layer.addSublayer(borderLayer)
    }
}
