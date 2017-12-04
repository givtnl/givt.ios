//
//  CustomUITextView.swift
//  ios
//
//  Created by Lennie Stockman on 15/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CustomUITextView: UITextView, UITextViewDelegate{
    private var originalColor: UIColor = UIColor.init(red: 234, green: 234, blue: 238)
    private var originalTextColor: UIColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
    override func awakeFromNib() {
        self.delegate = self
        self.layer.borderColor = originalColor.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 4
        self.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8)
        self.textColor = .lightGray
        self.font = UIFont(name: "Avenir-Light", size: 16.0)
    }
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBInspectable var placeholder: String? {
        didSet {
            self.text = placeholder
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = self.originalTextColor
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.lightGray
        }
    }
}
