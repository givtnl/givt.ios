//
//  Setting.swift
//  ios
//
//  Created by Lennie Stockman on 12/07/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit

class Setting {
    var name: String
    var image: UIImage
    var callback: () -> ()
    var showArrow: Bool
    var showBadge: Bool
    var isHighlighted: Bool
    
    init(name: String, image: UIImage, showBadge: Bool = false, callback: @escaping () -> (), showArrow: Bool = true, isHighlighted: Bool = false) {
        self.name = name
        self.image = image
        self.callback = callback
        self.showArrow = showArrow
        self.showBadge = showBadge
        self.isHighlighted = isHighlighted
    }

}
