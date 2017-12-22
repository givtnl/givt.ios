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
    var isHidden: Bool
    var callback: () -> ()
    var show: Bool
    var showArrow: Bool
    
    init(name: String, image: UIImage, isHidden: Bool = true, callback: @escaping () -> (), show: Bool = true, showArrow: Bool = true) {
        self.name = name
        self.image = image
        self.isHidden = isHidden
        self.callback = callback
        self.show = show
        self.showArrow = showArrow
    }

}
