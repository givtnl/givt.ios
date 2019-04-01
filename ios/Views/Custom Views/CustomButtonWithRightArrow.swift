//
//  CustomButtonWithRightArrow.swift
//  ios
//
//  Created by Mike Pattyn on 01/03/2019.
//  Copyright © 2019 Givt. All rights reserved.
//

import UIKit

@IBDesignable
class CustomButtonWithRightArrow : UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func awakeFromNib() {
        ogBGColor = backgroundColor
    }
    @IBAction func viewTouch(_ sender: Any) {
        sendActions(for: .touchUpInside)
    }
    
    @IBOutlet var contentView: UIButton!
    @IBOutlet var labelText: UILabel!
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var ogBGColor: UIColor? {
        didSet {
            backgroundColor = ogBGColor
        }
    }
    
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? highlightedBGColor : ogBGColor
        }
        
    }
    @IBInspectable var highlightedBGColor: UIColor?

    @IBInspectable var disabledColor: UIColor? {
        didSet {
            if let c = disabledColor {
                self.setBackgroundColor(color: c, forState: .disabled)
            }
        }
    }
    private func commonInit() {
        Bundle.main.loadNibNamed("CustomButtonWithRightArrow", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
