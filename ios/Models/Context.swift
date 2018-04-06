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
    case none
    case collectionDevice
    case qr
    case manually
}

class Context {
    var name: String
    var explanation: String
    var type: ContextType
    var image: UIImage
    
    init(name: String, explanation: String, type: ContextType, image: UIImage) {
        self.name = name
        self.explanation = explanation
        self.type = type
        self.image = image
    }
}
