//
//  RegistrationUser.swift
//  ios
//
//  Created by Lennie Stockman on 28/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation

import UIKit

class RegistrationUser {
    var email: String
    var password: String
    var firstName: String
    var lastName: String
    
    init(email: String, password: String, firstName: String, lastName: String) {
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
    }
}

class RegistrationUserData {
    var address: String = ""
    var city: String = ""
    var countryCode: String = ""
    var iban: String = ""
    var mobileNumber: String = ""
    var postalCode: String = ""
    
    init(address: String, city: String, countryCode: String, iban: String, mobileNumber: String, postalCode: String) {
        self.address = address
        self.city = city
        self.countryCode = countryCode
        self.iban = iban
        self.mobileNumber = mobileNumber
        self.postalCode = postalCode
    }
    
}
