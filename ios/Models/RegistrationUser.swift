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
    var address: String = ""
    var city: String = ""
    var country: String = ""
    var iban: String = ""
    var mobileNumber: String = ""
    var postalCode: String = ""
    var sortCode: String = ""
    var bacsAccountNumber: String = ""
    var timeZoneId: String = ""
    
    init(email: String, password: String, firstName: String, lastName: String, address: String, city: String, country: String, iban: String, mobileNumber: String, postalCode: String, sortCode: String, bacsAccountNumber: String, timeZoneId: String) {
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.address = address
        self.city = city
        self.country = country
        self.iban = iban
        self.mobileNumber = mobileNumber
        self.postalCode = postalCode
        self.sortCode = sortCode
        self.bacsAccountNumber = bacsAccountNumber
        self.timeZoneId = timeZoneId
    }
}
