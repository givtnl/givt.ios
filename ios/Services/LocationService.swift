//
//  LocationService.swift
//  ios
//
//  Created by Lennie Stockman on 8/05/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationServiceProtocol: class {
    func didDiscoverLocationInRegion(location: GivtLocation)
}

class LocationService: NSObject, CLLocationManagerDelegate {
    weak var delegate: LocationServiceProtocol?
    
    static let instance = LocationService()
    
    private let locationManager = CLLocationManager()
    var lastLocation: CLLocation?
    private var givtLocations: [GivtLocation] = [GivtLocation]()
    private var locationCheckTimer: Timer?
    private override init() {
        super.init()
    }
    
    func startLookingForLocation() {
        self.lastLocation = nil
        givtLocations = getGivtLocations()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        LogService.shared.info(message: "Started looking for location")
        locationCheckTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(checkAvailableLocations), userInfo: nil, repeats: true)
    }
    
    private func getGivtLocations() -> [GivtLocation] {
        var locations = [GivtLocation]()
        guard let list = UserDefaults.standard.orgBeaconListV2 else {
            return locations
        }
        list.OrgBeacons.forEach { (element) in
            element.Locations.forEach({ (location) in
                if Date().isBetween(location.dtBegin, and: location.dtEnd) {
                    locations.append(GivtLocation(lat: location.Latitude, long: location.Longitude, radius: location.Radius, name: location.Name, beaconId: location.BeaconId, organisationName: element.OrgName))
                }
            })
        }
        return locations
    }
    
    func stopLookingForLocation() {
        locationCheckTimer?.invalidate()
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        LogService.shared.info(message: "Stopped looking for location")
    }
    
    @objc func checkAvailableLocations() {
        guard self.lastLocation != nil else { return }
        var foundLocations = [GivtLocation]()
        givtLocations.forEach { (givtLocation) in
            if isLocationInRegion(region: givtLocation) {
                foundLocations.append(givtLocation)
            }
        }
        if foundLocations.count > 0 {
            LogService.shared.info(message: "Location was within region radius")
            let closestLocation = getClosestLocation(locs: foundLocations)
            delegate?.didDiscoverLocationInRegion(location: closestLocation)
        } else {
            LogService.shared.info(message: "Location was out of the radius of the region")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.lastLocation = locations.last!
    }
    
    func isLocationInRegion(region: GivtLocation) -> Bool {
        let fence = CLCircularRegion(center: CLLocationCoordinate2D(latitude: region.coordinate.coordinate.latitude, longitude: region.coordinate.coordinate.longitude), radius: CLLocationDistance(exactly: region.radius)!, identifier: region.name)
        guard let location = lastLocation else { return false }
        return fence.contains(location.coordinate)
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
