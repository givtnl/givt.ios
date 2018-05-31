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
    private override init() {
        super.init()
    }
    
    func startLookingForLocation() {
        self.lastLocation = nil
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        LogService.shared.info(message: "Started looking for location")
    }
    
    func stopLookingForLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        LogService.shared.info(message: "Stopped looking for location")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.lastLocation = locations.last!
    }
    
    func isLocationInRegion(region: GivtLocation) -> Bool {
        let fence = CLCircularRegion(center: CLLocationCoordinate2D(latitude: region.coordinate.coordinate.latitude, longitude: region.coordinate.coordinate.longitude), radius: CLLocationDistance(exactly: region.radius)!, identifier: region.name)
        guard let location = lastLocation else { return false }
        LogService.shared.info(message: "Checking for location in region")
        let contained = fence.contains(location.coordinate)
        if contained {
            LogService.shared.info(message: "Location was within region radius")
        } else {
            LogService.shared.info(message: "Location was out of the radius of the region")
        }
        return contained
    }
    
    func getClosestLocation(locs: [GivtLocation]) -> GivtLocation {
        var closestGivtLocation: GivtLocation?
        var closestGivtLocationInMeters: Double?
        
        if locs.count == 1 {
            return locs.first!
        }
        
        locs.forEach { (givtLocation) in
            if let _ = closestGivtLocation, let meters = closestGivtLocationInMeters {
                let currentDistance = lastLocation!.distance(from: givtLocation.coordinate)
                if currentDistance < meters {
                    closestGivtLocation = givtLocation
                    closestGivtLocationInMeters = currentDistance
                }
            } else {
                closestGivtLocation = givtLocation
                closestGivtLocationInMeters = lastLocation!.distance(from: givtLocation.coordinate)
            }
        }
        return closestGivtLocation!
    }
    
}

class GivtLocation {
    var coordinate: CLLocation
    var radius: Int //meter
    var name: String
    var beaconId: String
    var organisationName: String
    
    init(lat: CLLocationDegrees, long: CLLocationDegrees, radius: Int, name: String, beaconId: String, organisationName: String) {
        self.coordinate = CLLocation(latitude: lat, longitude: long)
        self.radius = radius
        self.name = name
        self.beaconId = beaconId
        self.organisationName = organisationName
    }
}
