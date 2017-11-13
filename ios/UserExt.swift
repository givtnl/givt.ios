//
//  UserExt.swift
//  ios
//
//  Created by Lennie Stockman on 28/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation
import UIKit

class UserExt: NSObject, NSCoding {
    var email: String = ""
    var password: String = ""
    var firstName: String = ""
    var lastName: String = ""
    
    var address: String = ""
    var city: String = ""
    var countryCode: String = ""
    var iban: String = ""
    var mobileNumber: String = ""
    var postalCode: String = ""
    var guid: String = ""    
    
    override init() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.email = aDecoder.decodeObject(forKey: "email") as! String
        self.password = aDecoder.decodeObject(forKey: "password") as! String
        self.firstName = aDecoder.decodeObject(forKey: "firstName") as! String
        self.lastName = aDecoder.decodeObject(forKey: "lastName") as! String
        
        self.address = aDecoder.decodeObject(forKey: "address") as! String
        self.city = aDecoder.decodeObject(forKey: "city") as! String
        self.countryCode = aDecoder.decodeObject(forKey: "countryCode") as! String
        self.iban = aDecoder.decodeObject(forKey: "iban") as! String
        self.mobileNumber = aDecoder.decodeObject(forKey: "mobileNumber") as! String
        self.postalCode = aDecoder.decodeObject(forKey: "postalCode") as! String
        self.guid = aDecoder.decodeObject(forKey: "guid") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(email, forKey: "email")
        aCoder.encode(password, forKey: "password")
        aCoder.encode(firstName, forKey: "firstName")
        aCoder.encode(lastName, forKey: "lastName")
        
        aCoder.encode(address, forKey: "address")
        aCoder.encode(city, forKey: "city")
        aCoder.encode(countryCode, forKey: "countryCode")
        aCoder.encode(iban, forKey: "iban")
        aCoder.encode(mobileNumber, forKey: "mobileNumber")
        aCoder.encode(postalCode, forKey: "postalCode")
        aCoder.encode(guid, forKey: "guid")        
    }
}
