//
//  AppServices.swift
//  ios
//
//  Created by Lennie Stockman on 23/08/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit
import CoreLocation

class AppServices {
    static let shared = AppServices()
    func connectedToNetwork() -> Bool {
    
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    func notificationsEnabled() -> Bool {
        return UIApplication.shared.isRegisteredForRemoteNotifications && !(UIApplication.shared.currentUserNotificationSettings?.types.isEmpty)!
    }
    
    static func isLocationPermissionGranted() -> Bool
    {
        guard CLLocationManager.locationServicesEnabled() else { return false }
        return [.authorizedAlways, .authorizedWhenInUse].contains(CLLocationManager.authorizationStatus())
    }
}
