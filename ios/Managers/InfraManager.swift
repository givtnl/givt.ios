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
    
    private func checkForUpdates() {
        var appVersion: [String: String] = [:]
        appVersion["BuildNumber"] = AppConstants.buildNumber
        appVersion["DeviceOS"] = "1"
        do {
            try client.post(url: "/api/CheckForUpdate", data: appVersion) { (response) in
                if let response = response {
                    
                    if response.basicStatus == .ok, let data = response.data {
                        do {
                            let parsedData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                            print(parsedData)
                        } catch {
                            self.log.warning(message: "could not parse json")
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
    
    func checkUpdates() {
        checkForUpdates()
    }
    
    func start() {
        checkUpdates()
    }
    
    func resume() {
        checkUpdates()
    }
    
}
