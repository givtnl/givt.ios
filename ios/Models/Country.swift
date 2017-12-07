//
//  Country.swift
//  ios
//
//  Created by Lennie Stockman on 5/10/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation
import UIKit

class Country {
    var name: String //eg Belgium
    var shortName: String //eg BE
    var prefix: String //eg +32
    
    init(name: String, shortName: String, prefix: String) {
        self.name = name
        self.shortName = shortName
        self.prefix = prefix
    }
    
    func toString() -> String {
        return self.name + " (" + self.prefix + ")"
    }
    
}
