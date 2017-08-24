//
//  BeaconServiceProtocol.swift
//  ios
//
//  Created by Lennie Stockman on 22/08/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation

protocol BeaconServiceProtocol {
    var bluetoothEnabled: Bool? { get }
    var isScanning: Bool? { get }
    
    func startScanning()
    func stopScanning()
}
