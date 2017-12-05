//
//  AppConstants.swift
//  ios
//
//  Created by Lennie Stockman on 08/08/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation

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
    
    static var buildNumber: String {
        get {
            /* TESTING PURPOSES ONLY */
            // UNCOMMENT one of the following lines to simulate the popup from the update
            //return "2" -> normal update
            //return "3" -> critical update
            //return "4" -> normal update
            
            return Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        }
    }
}
