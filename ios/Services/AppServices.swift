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
import Reachability
import CoreTelephony
import GivtCodeShare

class AppServices {
    static let shared = AppServices()
    private var timer: Timer?
    private let reachability = try? Reachability()
    private var isConnectable = true
    private var isReachable = true
    private let notificationLocker = NSRecursiveLock()
    var isServerReachable: Bool {
        get {
            return isConnectable && isReachable
        }
    }
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
    }
    
    func start() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(fetchInternetConnection), userInfo: nil, repeats: true)
        timer!.fire()
        do {
            try reachability?.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }
    }
    
    func stop() {
        timer?.invalidate()
        reachability?.stopNotifier()
    }
    
    @objc private func reachabilityChanged(note: Notification) {
        notificationLocker.lock()
        if let reachability = note.object as? Reachability {
            if isReachable {
                if reachability.connection == .none {
                    isReachable = false
                    isConnectable = false //if internet is turned off, we manually set this to false to indicate call to ping will also fail
                    NotificationCenter.default.post(Notification(name: .GivtConnectionStateDidChange, object: false, userInfo: nil))
                }
            } else {
                if reachability.connection != .none {
                    isReachable = true
                    timer!.fire() //let internetchecker fire notification
                }
            }
        }
        notificationLocker.unlock()
    }
    
    @objc private func fetchInternetConnection() {
        notificationLocker.lock()
        if isReachable {
            //clear cache. response was previously cached
            URLCache.shared.removeAllCachedResponses()
            GivtSDK.shared.infraClient().getStatus { result, _ in
                if let success: Bool = result as? Bool, success {
                    if !self.isConnectable {
                        self.isConnectable = success
                        NotificationCenter.default.post(Notification(name: .GivtConnectionStateDidChange, object: success, userInfo: nil))
                    }
                } else {
                    if self.isConnectable {
                        self.isConnectable = false
                        NotificationCenter.default.post(Notification(name: .GivtConnectionStateDidChange, object: false, userInfo: nil))
                    }
                }
            }
        }
        notificationLocker.unlock()
    }
    
    static func getCountryFromSim() -> String? {
//        let networkInfo = CTTelephonyNetworkInfo()
//
//        if let countryCode = networkInfo.subscriberCellularProvider?.isoCountryCode {
//            return countryCode.uppercased()
//        }
//        return nil
        return "US"
    }
    
    static func isCountryFromSimGB() -> Bool {
        switch(getCountryFromSim()) {
            case "GB", "GG", "JE":
                return true
            default:
                return false
        }
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
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
