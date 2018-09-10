//
//  Mandate.swift
//  ios
//
//  Created by Lennie Stockman on 29/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation
import UIKit


struct Mandate: Codable {
    var signatory: Signatory
    
    init(signatory: Signatory) {
        self.signatory = signatory
    }
}

struct Signatory: Codable {
    var givenName: String
    var familyName: String
    var bankAccount: BankAccount?
    var bacsAccount: BacsAccount?
    var email: String
    var telephone: String
    var billingAddress: BillingAddress
    
    init(givenName: String, familyName: String, iban: String?, sortCode: String?, accountNumber: String?, email: String, telephone: String, city: String, country: String, postalCode: String, street: String ) {
        self.givenName = givenName
        self.familyName = familyName
        self.email = email
        self.telephone = telephone
        self.billingAddress = BillingAddress(city: city, country: country, postalCode: postalCode, street: street)
        
        if iban != nil {
            self.bankAccount = BankAccount(iban: iban!)
        } else {
            self.bacsAccount = BacsAccount(sortCode: sortCode!, accountNumber: accountNumber!)
        }
    }
}

struct BankAccount: Codable {
    var iban: String
    init(iban: String) {
        self.iban = iban
    }
}

struct BacsAccount: Codable {
    var sortCode: String
    var accountNumber: String
    init(sortCode: String, accountNumber: String) {
        self.sortCode = sortCode
        self.accountNumber = accountNumber
    }
}

struct BillingAddress: Codable {
    var city: String
    var country: String
    var postalCode: String
    var street1: String
    
    init(city: String, country: String, postalCode: String, street: String) {
        self.city = city
        self.country = country
        self.postalCode = postalCode
        self.street1 = street
    }
}
