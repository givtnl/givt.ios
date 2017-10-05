//
//  Mandate.swift
//  ios
//
//  Created by Lennie Stockman on 29/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation
import UIKit

class Mandate {
    var signatory: [String: Any]
    
    init(signatory: Signatory) {
        self.signatory = signatory.toDictionary()
    }
    
    func toDictionary() -> [String : Any] {
        
        var dictionary = [String:Any]()
        let otherSelf = Mirror(reflecting: self)
        
        for child in otherSelf.children {
            
            if let key = child.label {
                dictionary[key] = child.value
            }
        }
        
        print("USER_DICTIONARY :: \(dictionary.description)")
        
        return dictionary
    }
}

class Signatory {
    var givenName: String
    var familyName: String
    var bankAccount: [String: Any]
    var email: String
    var telephone: String
    var billingAddress: [String: Any]
    
    init(givenName: String, familyName: String, iban: String, email: String, telephone: String, city: String, country: String, postalCode: String, street: String ) {
        self.givenName = givenName
        self.familyName = familyName
        self.bankAccount = BankAccount(iban: iban).toDictionary()
        self.email = email
        self.telephone = telephone
        self.billingAddress = BillingAddress(city: city, country: country, postalCode: postalCode, street: street).toDictionary()
    }
    
    func toDictionary() -> [String : Any] {
        
        var dictionary = [String:Any]()
        let otherSelf = Mirror(reflecting: self)
        
        for child in otherSelf.children {
            
            if let key = child.label {
                dictionary[key] = child.value
            }
        }
        
        print("USER_DICTIONARY :: \(dictionary.description)")
        
        return dictionary
    }
}

class BankAccount {
    var iban: String
    
    init(iban: String) {
        self.iban = iban
    }
    
    func toDictionary() -> [String : Any] {
        
        var dictionary = [String:Any]()
        let otherSelf = Mirror(reflecting: self)
        
        for child in otherSelf.children {
            
            if let key = child.label {
                dictionary[key] = child.value
            }
        }
        
        print("USER_DICTIONARY :: \(dictionary.description)")
        
        return dictionary
    }
}

class BillingAddress {
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
    
    func toDictionary() -> [String : Any] {
        
        var dictionary = [String:Any]()
        let otherSelf = Mirror(reflecting: self)
        
        for child in otherSelf.children {
            
            if let key = child.label {
                dictionary[key] = child.value
            }
        }
        
        print("USER_DICTIONARY :: \(dictionary.description)")
        
        return dictionary
    }
}
