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
        countries.append(Country(name: NSLocalizedString("Belgium", comment: ""), shortName: "BE", phoneNumber: PhoneNumber(prefix: "+32", firstNumbers: ["4"], length: 8)))
        countries.append(Country(name: NSLocalizedString("Netherlands", comment: ""), shortName: "NL", phoneNumber: PhoneNumber(prefix: "+31", firstNumbers: ["6"], length: 8)))
        countries.append(Country(name: NSLocalizedString("Germany", comment: ""), shortName: "DE", phoneNumber: PhoneNumber(prefix: "+49", firstNumbers: ["15","16","17"], length: 9)))
        countries.append(Country(name: NSLocalizedString("UnitedKingdom", comment: ""), shortName: "GB", phoneNumber: PhoneNumber(prefix: "+44", firstNumbers: ["7"], length: 9)))
        return countries
    }()

    
    enum CountryCodes: String {
        case UnitedKingdom = "GB"
        case Belgium = "BE"
        case Netherlands = "NL"
        case Germany = "DE"
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
    
    static var apiUri: String = {
        #if PRODUCTION
            return "https://api.givtapp.net" // do not put this in prod before release!
        #else
            return "https://givt-debug-api.azurewebsites.net"
            //return "http://localhost:5000"
        #endif
    }()
    
    static var appStoreUrl = "itms-apps://itunes.apple.com/app/id1181435988"
    
    static var trustKitConfig: [String: Any] = {
        let trustKitConfig = [
            kTSKSwizzleNetworkDelegates: false,
            kTSKPinnedDomains: [
                "api.givtapp.net": [
                    kTSKPublicKeyAlgorithms: [kTSKAlgorithmRsa2048],
                    kTSKPublicKeyHashes: [
                        "GnLdxcfpBNV0OtFuufExFJmkuj2oQYQrfLZ+KTy7A1w=",
                        "HnLdxcfpBNV0OtFuufExFJmkuj2oQYQrfLZ+KTy7A1w=" //fake pin
                    ]],
                "api.logit.io": [
                    kTSKExpirationDate: "2019-10-12",
                    kTSKPublicKeyAlgorithms: [kTSKAlgorithmRsa2048],
                    kTSKPublicKeyHashes: [
                        "/JvZY7DBIDt5NylYRKjYP76G3E0F/6C4X6u0bqosQok=",
                        "Slt48iBVTjuRQJTjbzopminRrHSGtndY0/sj0lFf9Qk="
                    ]],]
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
