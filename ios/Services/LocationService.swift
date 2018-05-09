//
//  LocationService.swift
//  ios
//
//  Created by Lennie Stockman on 8/05/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
    static let instance = LocationService()
    
    private let locationManager = CLLocationManager()
    var lastLocation: CLLocation?
    private var geoFenceRegion: CLCircularRegion?
    private override init() {
        super.init()
    }
    
    func startLookingForLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stopLookingForLocation() {
        locationManager.stopUpdatingLocation()
        lastLocation = nil
        locationManager.delegate = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.lastLocation = locations.last!
    }
    
    func isLocationInRegion(region: GivtLocation) -> Bool {
        let fence = CLCircularRegion(center: CLLocationCoordinate2D(latitude: region.lat, longitude: region.long), radius: CLLocationDistance(exactly: region.radius)!, identifier: region.name)
        guard let location = lastLocation else { return false }
        return fence.contains(location.coordinate)
    }
    
}
