//
//  CustomButton.swift
//  ios
//
//  Created by Lennie Stockman on 14/07/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation
import UIKit

class CustomButton: UIButton{
    override func awakeFromNib() {
        
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.init(rgb: 0x1ca96c) : UIColor.init(rgb: 0x41c98e)
        }
    }

}
