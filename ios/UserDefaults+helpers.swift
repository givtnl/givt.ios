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
        case userExt
        case mandateSigned
        case viewedCoachMarks
        case userClaims
        case orgBeaconList
        case hasTappedAwayGiveDiff
        case pinSet
    }
    
    var tempUser: Bool {
        get {
            return userExt?.iban == AppConstants.tempIban
        }
    }
    
    var hasPinSet: Bool {
        get {
            return bool(forKey: UserDefaultsKeys.pinSet.rawValue)
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.pinSet.rawValue)
        }
    }
    
    var hasTappedAwayGiveDiff: Bool {
        get {
            return bool(forKey: UserDefaultsKeys.hasTappedAwayGiveDiff.rawValue)
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.hasTappedAwayGiveDiff.rawValue)
        }
    }
    
    var orgBeaconList: NSDictionary? {
        get {
            if let list = dictionary(forKey: UserDefaultsKeys.orgBeaconList.rawValue) as NSDictionary? {
                return list
            }
            return nil
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.orgBeaconList.rawValue)
            synchronize()
        }
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
    
    var userClaims: Int {
        get {
            return integer(forKey: UserDefaultsKeys.userClaims.rawValue)
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.userClaims.rawValue)
            synchronize()
        }
    }
    
    var bearerToken: String? {
        get {
            return string(forKey: UserDefaultsKeys.bearerToken.rawValue)
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
    
    var userExt: UserExt! {
        get {
            if let encoded = data(forKey: UserDefaultsKeys.userExt.rawValue) {
                return NSKeyedUnarchiver.unarchiveObject(with: encoded) as! UserExt
            }
            return nil
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
