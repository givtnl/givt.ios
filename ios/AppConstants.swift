//
//  AppConstants.swift
//  ios
//
//  Created by Lennie Stockman on 08/08/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation
import TrustKit

class AppConstants{
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
        countries.append(Country(name: NSLocalizedString("Belgium", comment: ""), shortName: "BE", prefix: "+32"))
        countries.append(Country(name: NSLocalizedString("Netherlands", comment: ""), shortName: "NL", prefix: "+31"))
        countries.append(Country(name: NSLocalizedString("Germany", comment: ""), shortName: "DE", prefix: "+49"))
        return countries
    }()
    
    static var apiUri: String = {
        #if DEBUG
        return "https://givtapidebug.azurewebsites.net"
        #else
        //    return "https://givtapidebug.azurewebsites.net"
            return "https://api.givtapp.net" // do not put this in prod before release!
        #endif
    }()
    
    static var appStoreUrl = "itms-apps://itunes.apple.com/app/id1181435988"
    
    static var trustKitConfig: [String: Any] = {
        let trustKitConfig = [
            kTSKSwizzleNetworkDelegates: false,
            kTSKPinnedDomains: [
                "api.givtapp.net": [
                    kTSKExpirationDate: "2018-12-08",
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
}
