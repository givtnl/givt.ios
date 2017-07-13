//
//  RoundedButton.swift
//  GivtApp
//
//  Created by Lennie Stockman on 01/06/2017.
//  Copyright © 2017 Lennie Stockman. All rights reserved.
//

import Foundation
import UIKit

class RoundedButton: UIButton{
    override func awakeFromNib() {
        super.awakeFromNib();
        
        layer.borderWidth = 1/UIScreen.main.nativeScale
        layer.borderColor = UIColor.lightGray.cgColor
        layer.cornerRadius = 6;
    }
}
