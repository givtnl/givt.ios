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
        case isLoggedIn
        case bearerToken
        case bearerExpiration
        case amountLimit
        case offlineGivts
        case guid
        case userExt
        case mandateSigned
        case viewedCoachMarks
    }
    
    var isLoggedIn: Bool {
        get {
            return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
            synchronize()
        }
    }
    
    var guid: String {
        get {
            return string(forKey: UserDefaultsKeys.guid.rawValue)!
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.guid.rawValue)
            synchronize()
        }
    }
    
    var bearerToken: String {
        get {
            if string(forKey: UserDefaultsKeys.bearerToken.rawValue) != nil {
                return string(forKey: UserDefaultsKeys.bearerToken.rawValue)!
            }
            return ""
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.bearerToken.rawValue)
            synchronize()
        }
    }
    
    var bearerExpiration: Date {
        get {
            return object(forKey: UserDefaultsKeys.bearerExpiration.rawValue) as! Date
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.bearerExpiration.rawValue)
            synchronize()
        }
    }
    
    var amountLimit: Int {
        get {
            if object(forKey: UserDefaultsKeys.amountLimit.rawValue) != nil {
                return object(forKey: UserDefaultsKeys.amountLimit.rawValue) as! Int
            }
            return 0
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.amountLimit.rawValue)
            synchronize()
        }
    }
    
    var offlineGivts: [Transaction] {
        get {
            if(UserDefaults.standard.data(forKey: UserDefaultsKeys.offlineGivts.rawValue) != nil) {
                if NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.data(forKey: UserDefaultsKeys.offlineGivts.rawValue)!) != nil {
                    // print(temp)
                    return NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.data(forKey: UserDefaultsKeys.offlineGivts.rawValue)!) as! [Transaction]
                }
            }
            return [Transaction]()
        }
        set(value) {
            set(NSKeyedArchiver.archivedData(withRootObject: value), forKey: UserDefaultsKeys.offlineGivts.rawValue)
            synchronize()
        }
    }
    
    var userExt: UserExt {
        get {
            let encoded = data(forKey: UserDefaultsKeys.userExt.rawValue)
            return NSKeyedUnarchiver.unarchiveObject(with: encoded!) as! UserExt
        }
        set(value) {
            let encoded = NSKeyedArchiver.archivedData(withRootObject: value)
            set(encoded, forKey: UserDefaultsKeys.userExt.rawValue)
            synchronize()
        }
    }
    
    var mandateSigned: Bool {
        get {
            return bool(forKey: UserDefaultsKeys.mandateSigned.rawValue)
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.mandateSigned.rawValue)
            synchronize()
        }
    }
    
    var viewedCoachMarks: Int {
        get {
            return integer(forKey: UserDefaultsKeys.viewedCoachMarks.rawValue)
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.viewedCoachMarks.rawValue)
            synchronize()
        }
    }
}
