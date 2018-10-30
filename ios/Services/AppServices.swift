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
import AudioToolbox

class AppServices {
    static let shared = AppServices()
    private var timer: Timer?
    private var hasInternetConnection: Bool? {
        didSet {
            NotificationCenter.default.post(Notification(name: .GivtConnectionStateDidChange, object: hasInternetConnection, userInfo: nil))
        }
    }
    
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
        
        return (isReachable && !needsConnection) && hasInternetConnection ?? false
    }
    
    func start() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(fetchInternetConnection), userInfo: nil, repeats: true)
        timer!.fire()
    }
    
    func stop() {
        timer?.invalidate()
    }
    
    @objc private func fetchInternetConnection() {
        //clear cache. response was previously cached
        URLCache.shared.removeAllCachedResponses()
        APIClient.shared.get(url: "/api/v2/status", data: [:]) { (response) in
            if let r = response, r.basicStatus == .ok {
                if self.hasInternetConnection == nil || !self.hasInternetConnection! {
                    self.hasInternetConnection = true
                }
            } else {
                if self.hasInternetConnection == nil || self.hasInternetConnection! {
                    self.hasInternetConnection = false
                }
            }
        }
    }
    
    func notificationsEnabled() -> Bool {
        return UIApplication.shared.isRegisteredForRemoteNotifications && !(UIApplication.shared.currentUserNotificationSettings?.types.isEmpty)!
    }
    
    static func isLocationServicesEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    static func isLocationPermissionDetermined() -> Bool {
        return ![.notDetermined].contains(CLLocationManager.authorizationStatus())
    }
    
    static func isLocationPermissionGranted() -> Bool {
        return [.authorizedAlways, .authorizedWhenInUse].contains(CLLocationManager.authorizationStatus())
    }
    
    func vibrate() {
        AudioServicesPlayAlertSound(1520)
    }
}
