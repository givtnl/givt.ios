//
//  InfraManager.swift
//  ios
//
//  Created by Lennie Stockman on 4/12/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import Foundation

class InfraManager {
    static var shared = InfraManager()
    private let client = APIClient.shared
    private let log = LogService.shared
    
    private init() {
        
    }
    
    private func checkForUpdates(callback: @escaping(Bool?) -> Void) {
        var appVersion: [String: String] = [:]
        appVersion["BuildNumber"] = AppConstants.buildNumber
        appVersion["DeviceOS"] = "1"
        do {
            try client.post(url: "/api/CheckForUpdate", data: appVersion) { (response) in
                if let response = response {
                    if response.basicStatus == .ok, let data = response.data, let text = response.text {
                        if text == "" {
                            callback(nil)
                            return
                        }
                        
                        do {
                            let parsedData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                            print(parsedData)
                            let dbBuildNumber = Int(truncating: parsedData["BuildNumber"] as! NSNumber)
                            if dbBuildNumber > Int(AppConstants.buildNumber)! {
                                //new build number
                                if Bool(truncating: parsedData["Critical"] as! NSNumber) {
                                    callback(true)
                                } else {
                                    callback(false)
                                }
                            }
                        } catch {
                            self.log.info(message: "could not parse json")
                        }
                    }
                } else {
                    self.log.warning(message: "No response from checkforupdates")
                }
            }
        } catch {
            log.warning(message: "Could not post to checkforupdate")
        }
        
    }
    
    func checkUpdates(callback: @escaping(Bool?) -> Void) {
        checkForUpdates { (status) in
            callback(status)
        }
    }    
}
