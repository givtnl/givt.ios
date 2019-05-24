//
//  Context.swift
//  ios
//
//  Created by Lennie Stockman on 6/04/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
import UIKit

enum ContextType:String {
    case GiveWithBluetooth
    case GiveWithQR
    case GiveFromList
    case GiveToEvent
    
    var name: String {
        get { return String(describing: self) }
    }
}

class Context {
    var title: String
    var subtitle: String
    var type: ContextType
    var image: UIImage
    
    init(title: String, subtitle: String, type: ContextType, image: UIImage) {
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.image = image
    }
}
