//
//  AppConstants.swift
//  ios
//
//  Created by Lennie Stockman on 08/08/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation
import TrustKit

class AppConstants {
    
    static let tempUserPassword: String = "R4nd0mP@s$w0rd123"
    static let tempIban: String = "FB66GIVT12345678"
    static var AppVersionNumber: String {
        get {
            
            if let bundle = Bundle.main.infoDictionary {
                let version = bundle["CFBundleShortVersionString"] as! String
                let build = bundle["CFBundleVersion"] as! String
                return version + "." + build
            }
            return "?.?"
        }
    }

    static var countries: [Country] = {
        var countries: [Country] = []
        countries.append(Country(name: NSLocalizedString("Netherlands", comment: ""), shortName: "NL", phoneNumber: PhoneNumber(prefix: "+31", firstNumbers: ["6"], length: 8)))
        countries.append(Country(name: NSLocalizedString("Belgium", comment: ""), shortName: "BE", phoneNumber: PhoneNumber(prefix: "+32", firstNumbers: ["4"], length: 8)))
        countries.append(Country(name: NSLocalizedString("Germany", comment: ""), shortName: "DE", phoneNumber: PhoneNumber(prefix: "+49", firstNumbers: ["15","16","17"], length: 9)))
        countries.append(Country(name: NSLocalizedString("UnitedKingdom", comment: ""), shortName: "GB", phoneNumber: PhoneNumber(prefix: "+44", firstNumbers: ["7"], length: 9)))
        countries.append(Country(name: NSLocalizedString("Jersey", comment: ""), shortName: "JE", phoneNumber: PhoneNumber(prefix: "+44", firstNumbers: ["7"], length: 9)))
        countries.append(Country(name: NSLocalizedString("Guernsey", comment: ""), shortName: "GG", phoneNumber: PhoneNumber(prefix: "+44", firstNumbers: ["7"], length: 9)))
        
        var sortedCountries = CountryCodesSEPA.sorted() { $0.value < $1.value }
        for(key, value) in sortedCountries {
            if(value >= 6) {
                countries.append(Country(name: NSLocalizedString("CountryString"+key, comment: ""), shortName: key, phoneNumber: PhoneNumber(prefix: PhoneNumberPrefixesSEPA.first{$0.key.contains(key)}!.value, firstNumbers: [""], length: 0)))
            }
        }
        
        return countries.sorted(by: { $0.name < $1.name})
    }()

    static var CountryCodesSEPA: [String:Int] = {
        return ["BE":0,
                "NL":1,
                "DE":2,
                "FR":6,
                "IT":7,
                "LU":8,
                "GR":9,
                "PT":10,
                "ES":11,
                "FI":12,
                "AT":13,
                "CY":14,
                "EE":15,
                "LV":16,
                "LT":17,
                "MT":18,
                "SI":19,
                "SK":20,
                "IE":21,
                "AD":22]
    }()
    
    static var PhoneNumberPrefixesSEPA: [String: String] = {
        return ["BE":"+32",
                "NL":"+31",
                "DE":"+49",
                "FR":"+33",
                "IT":"+39",
                "LU":"+352",
                "GR":"+30",
                "PT":"+351",
                "ES":"+34",
                "FI":"+358",
                "AT":"+43",
                "CY":"+357",
                "EE":"+372",
                "LV":"+371",
                "LT":"+370",
                "MT":"+356",
                "SI":"+386",
                "SK":"+421",
                "IE":"+353",
                "AD":"+376"]
    }()
    
    enum CountryCodes: String {
        case UnitedKingdom = "GB"
        case Belgium = "BE"
        case Netherlands = "NL"
        case Germany = "DE"
        case Jersey = "JE"
        case Guernsey = "GG"
    }
    
    static var externalApps: [String: [String: String]] = {
        return ["org.kdgm.kerkdienstgemist":
                    [
                        "logo":"kerkdienstgemist",
                        "name":"Kerkdienst Gemist"
                    ],
                "org.opwekking":
                    [
                        "logo":"opwekking",
                        "name":"Opwekking 2019"
                    ]
               ]
    }()
    
    static var country: String = {
        if let userExt = UserDefaults.standard.userExt,
           UserDefaults.standard.isLoggedIn,
           let country = userExt.country {
            return country
        } else if let country = AppServices.getCountryFromSim() {
            return country
        } else {
            return "NL"
        }
    }()
    static var usCountries = ["US", "CA", "MX","UY",
                              "AR","CL","PA","PR",
                              "CR","DO","MA"]
    static var apiUri: String = {
#if PRODUCTION
        if usCountries.contains(where: { $0 == country.uppercased() }) {
            return "https://api.givt.app" // do not put this in prod before release!
        } else {
            return "https://api.givtapp.net" // do not put this in prod before release!
        }
#else
        return "https://givt-debug-api.azurewebsites.net"
        //return "http://localhost:5000"
#endif
    }()
    
    static var cloudApiUri: String = {
#if PRODUCTION
        if usCountries.contains(where: { $0 == country.uppercased() }) {
            return "https://api.production.givt.app" // do not put this in prod before release!
        } else {
            return "https://api.production.givtapp.net"
        }
#else
        return "https://api.development.givtapp.net"
#endif
    }()
    
    static var advertisementsApiUrl: String = {
        #if PRODUCTION
            return "https://advertisements.givtapp.net"
        #else
            return "https://advertisements-develop.givtapp.net"
        #endif
    }()
    
    static var mixpanelProjectId: String = {
        #if PRODUCTION
            return "03cf660868058915f0ff4d3cc45371b9"
        #else
            return "408ddc540995656bdbd17c2f61df7ce2"
        #endif
    }()
    
    static var appStoreUrl = "itms-apps://itunes.apple.com/app/id1181435988"
    
    static var trustKitConfig: [String: Any] = {
        let trustKitConfig = [
            kTSKSwizzleNetworkDelegates: false,
            kTSKPinnedDomains: [
                "advertisements-develop.givtapp.net": [
                    kTSKPublicKeyHashes: [
                        "++MBgDH5WGvL9Bcn5Be30cRcL0f5O+NyoXuWtQdX1aI=", //Amazon Root CA pin
                        "HnLdxcfpBNV0OtFuufExFJmkuj2oQYQrfLZ+KTy7A1w=" //fake pin
                    ]
                ],
                "advertisements.givtapp.net": [
                    kTSKPublicKeyHashes: [
                        "++MBgDH5WGvL9Bcn5Be30cRcL0f5O+NyoXuWtQdX1aI=", //Amazon Root CA pin
                        "HnLdxcfpBNV0OtFuufExFJmkuj2oQYQrfLZ+KTy7A1w=" //fake pin
                    ]
                ],
                "api.production.givtapp.net" : [
                    kTSKPublicKeyHashes: [
                        "++MBgDH5WGvL9Bcn5Be30cRcL0f5O+NyoXuWtQdX1aI=", //Amazon Root CA pin
                        "HnLdxcfpBNV0OtFuufExFJmkuj2oQYQrfLZ+KTy7A1w=" //fake pin
                    ]
                ],
                "api.development.givtapp.net" : [
                    kTSKPublicKeyHashes: [
                        "++MBgDH5WGvL9Bcn5Be30cRcL0f5O+NyoXuWtQdX1aI=", //Amazon Root CA pin
                        "HnLdxcfpBNV0OtFuufExFJmkuj2oQYQrfLZ+KTy7A1w=" //fake pin
                    ]
                ],
                "api.production.givt.app" : [
                    kTSKPublicKeyHashes: [
                        "++MBgDH5WGvL9Bcn5Be30cRcL0f5O+NyoXuWtQdX1aI=", //Amazon Root CA pin
                        "HnLdxcfpBNV0OtFuufExFJmkuj2oQYQrfLZ+KTy7A1w=" //fake pin
                    ]
                ],
                "api.givtapp.net": [
                    kTSKPublicKeyHashes: [
                        "QLyh2geWh6rcEgzp4tGPeA3GaxEiXbvRlayQRF+BA38=",
                        "HnLdxcfpBNV0OtFuufExFJmkuj2oQYQrfLZ+KTy7A1w=" //fake pin
                    ]
                ],
                "api.givt.app": [
                    kTSKPublicKeyHashes: [
                        "J2/oqMTsdhFWW/n85tys6b4yDBtb6idZayIEBx7QTxA=",
                        "HnLdxcfpBNV0OtFuufExFJmkuj2oQYQrfLZ+KTy7A1w="
                    ]
                ],
                "api.logit.io": [
                    kTSKExpirationDate: "2019-10-12",
                    kTSKPublicKeyHashes: [
                        "/JvZY7DBIDt5NylYRKjYP76G3E0F/6C4X6u0bqosQok=",
                        "Slt48iBVTjuRQJTjbzopminRrHSGtndY0/sj0lFf9Qk="
                    ]
                ]
            ]
        ] as [String : Any]
        return trustKitConfig
    }()
    
    static var buildNumber: String {
        get {
            #if DEBUG
            /* TESTING PURPOSES ONLY */
            // UNCOMMENT one of the following lines to simulate the popup from the update
            //return "2" //-> normal update
            //return "3" -> critical update
            return "4" //-> normal update
            return Bundle.main.infoDictionary!["CFBundleVersion"] as! String
            #else
            return Bundle.main.infoDictionary!["CFBundleVersion"] as! String
            #endif
        }
    }
    
    static var returnUrlDir: String {
        get {
            return "natived"
        }
    }
    
    static var appScheme: String {
        get {
            let urlTypes = Bundle.main.infoDictionary!["CFBundleURLTypes"] as! NSArray
            return (((urlTypes[0] as! NSDictionary).value(forKey: "CFBundleURLSchemes")) as! NSArray)[0] as! String + "://"
        }
    }
    
    static var appcenterId: String = {
        #if PRODUCTION
            return "1cf2ecca-1ceb-4bd9-87f9-c3aface80e0b"
        #else
            return "eb8799f0-c64e-4447-bdc6-3e3d27ddf4bf"
        #endif
    }()
}
