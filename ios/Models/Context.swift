//
//  Context.swift
//  ios
//
//  Created by Lennie Stockman on 6/04/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
import UIKit

enum ContextType {
    case collectionDevice
    case qr
    case manually
    case events
}

class Context {
    var name: String
    var type: ContextType
    var image: UIImage
    
    init(name: String, type: ContextType, image: UIImage) {
        self.name = name
        self.type = type
        self.image = image
    }
}
