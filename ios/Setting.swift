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
    
    init(name: String, image: UIImage, callback: @escaping () -> ()) {
        self.name = name
        self.image = image
        self.callback = callback
    }

}
