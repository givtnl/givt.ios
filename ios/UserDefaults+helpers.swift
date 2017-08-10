//
//  UserDefaults+helpers.swift
//  ios
//
//  Created by Lennie Stockman on 08/08/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    enum UserDefaultsKeys: String {
        case IsLoggedIn
        case BearerToken
        case BearerExpiration
        case AmountLimit
    }
    
    var isLoggedIn: Bool {
        get {
            return bool(forKey: UserDefaultsKeys.IsLoggedIn.rawValue)
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.IsLoggedIn.rawValue)
            synchronize()
        }
    }
    
    var bearerToken: String {
        get {
            return string(forKey: UserDefaultsKeys.BearerToken.rawValue)!
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.BearerToken.rawValue)
            synchronize()
        }
    }
    
    var bearerExpiration: Date {
        get {
            return object(forKey: UserDefaultsKeys.BearerExpiration.rawValue) as! Date
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.BearerExpiration.rawValue)
            synchronize()
        }
    }
    
    var amountLimit: Int {
        get {
            return integer(forKey: UserDefaultsKeys.AmountLimit.rawValue)
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.AmountLimit.rawValue)
            synchronize()
        }
    }
}
