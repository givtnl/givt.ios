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
        case presetsSet
        case needsCriticalUpdate
        case termsVersion
        case showedLastYearTaxOverview
        case hasGivtsInPreviousYear
        case lastGivtToOrganisation
        case lastGivtToOrganisation_name
        @available(*, deprecated, message: "Do not use. Use showCasesByUserId instead.")
        case showcases              //deprecated
        case showCasesByUserID
        case orgBeaconListV2
        case tempUser
        case amountPresets
        case accountType
        case fingerprintSet
        case badges
        case yearsWithGivts
        case lastFeatureShown
        case featureBadges
        case notificationsEnabled
        case deviceToken
        case giftAidEnabled
        case giftAidSettings
        case toHighlightMenuList
        case testimonialsByUserId
    }
    
    enum Showcase: String {
        case cancelGivt
        case taxOverview
        case giveDifferently
        case giveSituation
        case multipleCollects
        case deleteMultipleCollects
    }
    
    var currencySymbol: String {
        get {
            switch accountType {
            case AccountType.sepa:
                return "€"
            case AccountType.bacs:
                return "£"
            case AccountType.undefined:
                return NSLocale.current.currencySymbol ?? "€"
            }
        }
    }
    
    var badges: [Int] {
        get {
            guard let badges = array(forKey: UserDefaultsKeys.badges.rawValue) as? [Int] else {
                return [Int]()
            }
            return badges
        }
        set(value)
        {
            set(value, forKey: UserDefaultsKeys.badges.rawValue)
            synchronize()
        }
    }
    
    var toHighlightMenuList: [String] {
        get {
            guard let toHighlightMenuList = array(forKey: UserDefaultsKeys.toHighlightMenuList.rawValue) as? [String] else { return [String]()}
            return toHighlightMenuList
        }
        set(value)
        {
            set(value, forKey: UserDefaultsKeys.toHighlightMenuList.rawValue)
            synchronize()
        }
    }
    
    var accountType: AccountType { //BACS of SEPA
        get {
            if let accTypeString = string(forKey: UserDefaultsKeys.accountType.rawValue)?.lowercased(){
                if let accType = AccountType(rawValue: accTypeString){
                    return accType
                } else {
                    return .undefined
                }
            } else {
                return .undefined
            }
        }
        set(value) {
            set(value.rawValue, forKey: UserDefaultsKeys.accountType.rawValue)
            synchronize()
        }
    }
    
    var amountPresets: [Decimal] {
        get {
            if let data = object(forKey: UserDefaultsKeys.amountPresets.rawValue) as? NSData {
                if let amountPresetByUserId = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [String: [Decimal]],
                    let decimals = amountPresetByUserId[userExt?.guid ?? ""]  {
                    return decimals
                }
            }
            return [2.50,7.50,12.50]
        }
        set(value) {
            var amountPresetByUserId: [String: [Decimal]] = [:]
            if let data = object(forKey: UserDefaultsKeys.amountPresets.rawValue) as? NSData {
                if let unarchivedDictionary = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [String: [Decimal]]  {
                    amountPresetByUserId = unarchivedDictionary
                }
            }
            
            if let uext = userExt {
                amountPresetByUserId[uext.guid] = value
                let data = NSKeyedArchiver.archivedData(withRootObject: amountPresetByUserId)
                set(data, forKey: UserDefaultsKeys.amountPresets.rawValue)
                synchronize()
            }
        }
    }
    
    var orgBeaconListV2: BeaconList? {
        get {
            if let data = UserDefaults.standard.value(forKey:UserDefaultsKeys.orgBeaconListV2.rawValue) as? Data {
                let beaconList = try? PropertyListDecoder().decode(BeaconList.self, from: data)
                return beaconList
            }
            return nil
        }
        set(value) {
            set(try? PropertyListEncoder().encode(value), forKey: UserDefaultsKeys.orgBeaconListV2.rawValue)
            synchronize()
        }
    }
    
    var showCasesByUserID: [String] {
        get {
            if let showcaseDict = dictionary(forKey: UserDefaultsKeys.showCasesByUserID.rawValue) as? [String: [String]] {
                if let uext = userExt, let retArray = showcaseDict[uext.guid] {
                    return retArray
                } else {
                    return []
                }
            } else {
                return []
            }
        }
        set(value) {
            var showcaseDict: [String: [String]] = [:]
            if let originalDict = dictionary(forKey: UserDefaultsKeys.showCasesByUserID.rawValue) as? [String: [String]] {
                showcaseDict = originalDict
            }
            
            if let uext = userExt {
                showcaseDict[uext.guid] = value
                set(showcaseDict, forKey: UserDefaultsKeys.showCasesByUserID.rawValue)
            }
            synchronize()
        }
    }

    @available(*, deprecated, message: "Do not use. Use showCasesByUserId instead.")
    var showcases: [String] {
        get {
            if let stringArray = stringArray(forKey: UserDefaultsKeys.showcases.rawValue) {
                return stringArray
            } else {
                return []
            }
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.showcases.rawValue)
            synchronize()
        }
    }
    
    var lastGivtToOrganisationNamespace: String? {
        get {
            return string(forKey: UserDefaultsKeys.lastGivtToOrganisation.rawValue)
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.lastGivtToOrganisation.rawValue)
            synchronize()
        }
    }
    var lastGivtToOrganisationName: String? {
        get {
            return string(forKey: UserDefaultsKeys.lastGivtToOrganisation_name.rawValue)
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.lastGivtToOrganisation_name.rawValue)
            synchronize()
        }
    }
    
    var hasFingerprintSet: Bool {
        get {
            if let fingerprintByGuid = dictionary(forKey: UserDefaultsKeys.fingerprintSet.rawValue) as? [String: Bool],
                let u = userExt,
                let value = fingerprintByGuid[u.guid] {
                return value
            }
            return false
        }
        set(value) {
            var fingerprintPerGuid: [String: Bool] = [:]
            if let original = dictionary(forKey: UserDefaultsKeys.fingerprintSet.rawValue) as? [String: Bool] {
                fingerprintPerGuid = original
            }
            
            if let uExt = userExt {
                fingerprintPerGuid[uExt.guid] = value
                set(fingerprintPerGuid, forKey: UserDefaultsKeys.fingerprintSet.rawValue)
            }
            synchronize()
        }
    }
    
    var hasGivtsInPreviousYear: Bool {
        get {
            return bool(forKey: UserDefaultsKeys.hasGivtsInPreviousYear.rawValue)
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.hasGivtsInPreviousYear.rawValue)
            synchronize()
        }
    }
    
    var showedLastYearTaxOverview: Bool {
        get {
            return bool(forKey: UserDefaultsKeys.showedLastYearTaxOverview.rawValue)
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.showedLastYearTaxOverview.rawValue)
            synchronize()
        }
    }
    
    var yearsWithGivts: [Int] {
        get {
            return array(forKey: UserDefaultsKeys.yearsWithGivts.rawValue) as! [Int]
        }
        set(value){
            set(value, forKey: UserDefaultsKeys.yearsWithGivts.rawValue)
            synchronize()
        }
    }
    
    var needsCriticalUpdate: Bool {
        get {
            return bool(forKey: UserDefaultsKeys.needsCriticalUpdate.rawValue)
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.needsCriticalUpdate.rawValue)
            synchronize()
        }
    }
    
    var isTempUser: Bool {
        get {
            return bool(forKey: UserDefaultsKeys.tempUser.rawValue)
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.tempUser.rawValue)
            synchronize()
        }
    }
    
    var hasPresetsSet: Bool? {
        get {
            if let bool = bool(forKey: UserDefaultsKeys.presetsSet.rawValue) as Bool? {
                return bool
            }
            return nil
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.presetsSet.rawValue)
            synchronize()
        }
    }
    var hasPinSet: Bool {
        get {
            return bool(forKey: UserDefaultsKeys.pinSet.rawValue)
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.pinSet.rawValue)
            synchronize()
        }
    }
    
    var hasTappedAwayGiveDiff: Bool {
        get {
            return bool(forKey: UserDefaultsKeys.hasTappedAwayGiveDiff.rawValue)
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.hasTappedAwayGiveDiff.rawValue)
            synchronize()
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
    
    var userExt: UserExt? {
        get {
            if let encoded = data(forKey: UserDefaultsKeys.userExt.rawValue) {
                return NSKeyedUnarchiver.unarchiveObject(with: encoded) as? UserExt
            }
            return nil
        }
        set(value) {
            let encoded = NSKeyedArchiver.archivedData(withRootObject: value!)
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
    
    var termsVersion: String? {
        get {
            return string(forKey: UserDefaultsKeys.termsVersion.rawValue)
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.termsVersion.rawValue)
            synchronize()
        }
    }
    
    var deviceToken: String? {
        get {
            return string(forKey: UserDefaultsKeys.deviceToken.rawValue)
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.deviceToken.rawValue)
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

    var lastFeatureShown: Int {
        get {
            if(UserDefaults.standard.object(forKey: "lastFeatureShown") != nil) {
                return integer(forKey: UserDefaultsKeys.lastFeatureShown.rawValue)
            } else {
                return 0
            }
            
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.lastFeatureShown.rawValue)
            synchronize()
        }
    }
    
    var featureBadges: [Int] {
        get {
            if let badges = array(forKey: UserDefaultsKeys.featureBadges.rawValue) as? [Int] {
                return badges
            }
            return []
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.featureBadges.rawValue)
            synchronize()
        }
    }
    
    var giftAidEnabled: Bool{
        get {
            return bool(forKey: UserDefaultsKeys.giftAidEnabled.rawValue)
        }
        set(value) {
            set(value, forKey: UserDefaultsKeys.giftAidEnabled.rawValue)
            synchronize()
        }
    }
    
    var giftAidSettings: GiftAidSettings? {
        get {
            if let giftAidSettings = data(forKey: UserDefaultsKeys.giftAidSettings.rawValue) {
                return NSKeyedUnarchiver.unarchiveObject(with: giftAidSettings) as? GiftAidSettings
            }
            return nil
        }
        set(value) {
            let encoded = NSKeyedArchiver.archivedData(withRootObject: value)
            set(encoded, forKey: UserDefaultsKeys.giftAidSettings.rawValue)
            synchronize()
        }
    }
    
    var lastShownTestimonial: TestimonialSetting? {
        get {
            if let data = data(forKey: UserDefaultsKeys.testimonialsByUserId.rawValue) {
                if let testimonialDictonary = try? JSONDecoder().decode([String: TestimonialSetting].self, from: data) {
                    if let uExt = userExt {
                        return testimonialDictonary[uExt.guid]
                    } else {
                        return nil
                    }
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
        set(value) {
            var testimonialDictonary: [String: TestimonialSetting] = [:]
            
            if let data = data(forKey: UserDefaultsKeys.testimonialsByUserId.rawValue) {
                if let originalDictionary = try? JSONDecoder().decode([String: TestimonialSetting].self, from: data) {
                    testimonialDictonary = originalDictionary
                }
            }
            
            if let uExt = userExt {
                testimonialDictonary[uExt.guid] = value
                set(try? JSONEncoder().encode(testimonialDictonary), forKey: UserDefaultsKeys.testimonialsByUserId.rawValue)
            }
            synchronize()
        }
    }
}

struct TestimonialSetting: Encodable, Decodable {
    var id: Int
    var date: String
}
