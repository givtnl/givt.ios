//
//  Beacon.swift
//  ios
//
//  Created by Bjorn Derudder on 25/07/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation

class Beacon{
    var EddyId: String
    var BatteryStatus: Int
    
    init(eddyID: String, batteryStatus: Int) {
        self.EddyId = eddyID
        self.BatteryStatus = batteryStatus
    }
    
    func convertToDictionary() -> Dictionary<String, Any> {
        return [
            "EddyId"   : self.EddyId,
            "BatteryStatus" : self.BatteryStatus
        ]
    }
}
