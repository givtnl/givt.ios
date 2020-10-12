//
//  TrackingHelper.swift
//  ios
//
//  Created by Mike Pattyn on 07/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import Foundation
import Mixpanel
import CoreBluetooth

class TrackingHelper {
    static func trackLocationPermissionStatus(rawValue: Int32) {
        let permissionStatus = LocationAuthorizationState(rawValue: Int(rawValue))!.description
        Mixpanel.mainInstance().track(event: "GIVE_LOCATION_LOCATION_PERMISSIONS_CHANGED", properties: ["PERMISSION_STATUS": permissionStatus])
    }
    static func trackBluetoothPermissionStatus(rawValue: Int) {
        let permissionStatus = BluetoothAuthorizationState(rawValue: rawValue)!.description
        Mixpanel.mainInstance().track(event: "GIVE_LOCATION_BLUETOOTH_PERMISSIONS_CHANGED", properties: ["PERMISSION_STATUS": permissionStatus])
    }
}


protocol EnumStringDescriptionProtocol {
    var description: String { get }
}
enum BluetoothAuthorizationState: Int, EnumStringDescriptionProtocol{
    case unknown = 0
    case resetting = 1
    case unsupported = 2
    case unauthorized = 3
    case poweredOff = 4
    case poweredOn = 5
    
    var description: String {
        switch self {
        case .unknown:
            return "UNKNOWN"
        case .resetting:
            return "RESETTING"
        case .unsupported:
            return "UNSUPPORTED"
        case .unauthorized:
            return "UNAUTHORIZED"
        case .poweredOff:
            return "POWERED_OFF"
        case .poweredOn:
            return "POWERED_ON"
        }
    }
}
enum LocationAuthorizationState : Int, EnumStringDescriptionProtocol {
    case notDetermined = 0
    case restricted = 1
    case denied = 2
    case authorizedAlways = 3
    case authorizedWhenInUse = 4
    
    var description: String {
        switch self {
        case .notDetermined:
            return "NOT_DETERMINED"
        case .restricted:
            return "RESTRICTED"
        case .denied:
            return "DENIED"
        case .authorizedAlways:
            return "AUTHORIZED_ALWAYS"
        case .authorizedWhenInUse:
            return "AUTHORIZED_WHEN_IN_USE"
        }
    }
}
