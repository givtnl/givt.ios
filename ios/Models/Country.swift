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
    var phoneNumber: PhoneNumber
    
    init(name: String, shortName: String, phoneNumber: PhoneNumber ) {
        self.name = name
        self.shortName = shortName
        self.phoneNumber = phoneNumber
        
    }
    
    func toString() -> String {
        return self.name + " (" + self.phoneNumber.prefix + ")"
    }
    
}
class PhoneNumber {
    var prefix: String
    var firstNumber: String
    var length: Int
    
    init(prefix: String, firstNumber: String, length: Int){
        self.prefix = prefix
        self.firstNumber = firstNumber
        self.length = length
    }
}
