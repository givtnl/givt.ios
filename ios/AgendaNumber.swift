//
//  AgendaNumber.swift
//  Playground
//
//  Created by Lennie Stockman on 13/09/17.
//  Copyright © 2017 Lennie Stockman. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class AgendaNumber: UIView {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
}
