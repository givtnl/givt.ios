//
//  BeaconService.swift
//  ios
//
//  Created by Lennie Stockman on 31/05/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

enum ScanMode {
    case close //traditional
    case far //"a" beacons
}

enum BluetoothState {
    case unknown
    case enabled
    case disabled
    case unauthorized
}

protocol BeaconServiceProtocol: class {
    func didUpdateBluetoothState(bluetoothState: BluetoothState)
    func didDetectBeacon(scanMode: ScanMode, bestBeacon: BestBeacon)
    func didUpdateBestBeacon(bestBeacon: BestBeacon)
}

class BeaconService: NSObject, CBCentralManagerDelegate {
    weak var delegate: BeaconServiceProtocol?
    private var centralManagerInstance: CBCentralManager! = nil
    private var centralManager: CBCentralManager! {
        get {
            if centralManagerInstance == nil {
                centralManagerInstance = CBCentralManager(delegate: self, queue: DispatchQueue.global(qos: .userInitiated), options: [CBCentralManagerOptionShowPowerAlertKey:false])
            }
            return centralManagerInstance
        }
    }
    private let log = LogService.shared
    private var bestBeacon: BestBeacon = BestBeacon()
    private var scannedPeripherals: [String: Int] = [String: Int]()
    private let rssiTreshold: Int = -68
    private var scanMode: ScanMode?
        
    func getBluetoothState() -> BluetoothState {
        switch centralManager.state {
        case .poweredOn:
            return .enabled
        case .unknown:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.keepCheckingBluetoothState()
            })
            return .unknown
        case .poweredOff:
            return .disabled
        case .unauthorized:
            return .unauthorized
        default:
            return .disabled
        }
    }
    
    private func keepCheckingBluetoothState()  {
        if UIApplication.shared.applicationState == .active {
            if self.centralManager.state == .poweredOn {
                self.delegate?.didUpdateBluetoothState(bluetoothState: .enabled)
            } else {
                self.delegate?.didUpdateBluetoothState(bluetoothState: .disabled)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.keepCheckingBluetoothState()
            })
        }
    }
    
    var isScanning: Bool {
        get {
            return centralManager.isScanning
        }
    }
    
    override init() {
        super.init()
    }
    
    func startScanning(mode: ScanMode) {
        self.scanMode = mode
        centralManager.scanForPeripherals(withServices: [GivtManager.FEAA], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }

    func stopScanning() {
        centralManager.stopScan()
        self.scanMode = nil
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let feaa = advertisementData[CBAdvertisementDataServiceDataKey] as! NSMutableDictionary? {
            let x = feaa.object(forKey: CBUUID(string: "FEAA"))
            if(x != nil){
                let y = String.init(describing: x!).replacingOccurrences(of: " ", with: "").lowercased()
                
                if y.contains("61f7ed01") || y.contains("61f7ed02") || y.contains("61f7ed03") {
                    let namespace = y[y.index(of: "61f7ed")!..<y.index(y.index(of: "61f7ed")!, offsetBy: 20)]
                    let instance = y[y.index(y.index(of: "61f7ed")!, offsetBy: 20)..<y.index(y.index(of: "61f7ed")!, offsetBy: 32)]
                    let antennaID = String(format: "%@.%@", String(namespace), String(instance))
                    beaconDetected(antennaID: antennaID, rssi: RSSI, beaconType: 0, peripheralId: peripheral.identifier)
                }
                
                if y.substring(1..<3) == "20" {
                    let batteryLevel = y.substring(5..<9)
                    if let value = Int(batteryLevel, radix: 16) {
                        scannedPeripherals[peripheral.identifier.uuidString] = value
                    }
                }
            }
        }
    }
    
    private func beaconDetected(antennaID: String, rssi: NSNumber, beaconType: Int8, peripheralId: UUID) {
        var msg = "Beacon detected \(antennaID) | RSSI: \(rssi)"
        if let bv = scannedPeripherals[peripheralId.uuidString] {
            msg += " | Battery voltage: \(bv)"
            if bv < 2450 && bv > 0 {
                self.log.warning(message: msg)
                let beacon = Beacon(eddyID: antennaID, batteryStatus: bv)
                do {
                    try APIClient.shared.put(url: "/api/v2/beacons/\(antennaID)/?userId=\(UserDefaults.standard.userExt!.guid)", data: beacon.convertToDictionary()) { (res) in }
                } catch {
                    self.log.error(message: "Unknown error : \(error)")
                }
            }else{
                self.log.info(message: msg)
            }
        } else {
            self.log.info(message: msg)
        }
        
        if(rssi != 0x7f){
            var organisation = antennaID
            if let idx = antennaID.index(of: ".") {
                organisation = String(antennaID[..<idx])
            }
            
            if let _ = bestBeacon.beaconId, let bestBeaconRssi = bestBeacon.rssi {
                /* beacon exists */
                if bestBeaconRssi.intValue < rssi.intValue { //update rssi when bigger
                    bestBeacon.rssi = rssi
                }
                bestBeacon.beaconId = antennaID
                bestBeacon.namespace = organisation
            } else {
                /* new beacon */
                bestBeacon.beaconId = antennaID
                bestBeacon.rssi = rssi
                bestBeacon.namespace = organisation
            }
            
            self.delegate?.didUpdateBestBeacon(bestBeacon: bestBeacon)
            
            let isAreaBeacon = String(bestBeacon.beaconId![bestBeacon.beaconId!.index(bestBeacon.beaconId!.index(of: ".")!, offsetBy: 1)]).lowercased() == "a"
            if let scanMode = scanMode {
                if scanMode == .close && !isAreaBeacon {
                    if rssi.intValue > rssiTreshold {
                        self.delegate?.didDetectBeacon(scanMode: scanMode, bestBeacon: bestBeacon)
                    }
                } else if scanMode == .far && isAreaBeacon {
                    self.delegate?.didDetectBeacon(scanMode: scanMode, bestBeacon: bestBeacon)
                } else {
                    self.log.info(message: "Beacon detected but did not meet requirements to trigger")
                }
            } else {
                self.log.error(message: "No active scanning mode found.")
            }
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        TrackingHelper.trackBluetoothPermissionStatus(rawValue: central.state.rawValue)
        if #available(iOS 10.0, *) {
            switch (central.state) {
            case .poweredOff:
                print("CBCentralManagerState.PoweredOff")
                delegate?.didUpdateBluetoothState(bluetoothState: .disabled)
                NotificationCenter.default.post(name: Notification.Name("BluetoothIsOff"), object: nil)
            case .unknown, .resetting, .unsupported:
                print(central.state)
                break
            case .unauthorized:
                print("CBCentralManagerState.Unauthorized")
                delegate?.didUpdateBluetoothState(bluetoothState: .unauthorized)
                NotificationCenter.default.post(name: Notification.Name("BluetoothIsUnauthorized"), object: nil)
            case .poweredOn:
                // check wether we were scanning before. if so, restart scanning
                if let mode = scanMode {
                    startScanning(mode: mode)
                }
                print("CBCentralManagerState.PoweredOn")
                delegate?.didUpdateBluetoothState(bluetoothState: .enabled)
                NotificationCenter.default.post(name: Notification.Name("BluetoothIsOn"), object: nil)
                break
            }
        } else {
            switch (central.state) {
            case .poweredOff:
                print("CBCentralManagerState.PoweredOff")
                delegate?.didUpdateBluetoothState(bluetoothState: .disabled)
                NotificationCenter.default.post(name: Notification.Name("BluetoothIsOff"), object: nil)
            case .unauthorized, .unknown, .resetting:
                print(central.state)
                break
            case .poweredOn:
                // check wether we were scanning before. if so, restart scanning
                if let mode = scanMode {
                    startScanning(mode: mode)
                }
                print("CBCentralManagerState.PoweredOn")
                delegate?.didUpdateBluetoothState(bluetoothState: .enabled)
                NotificationCenter.default.post(name: Notification.Name("BluetoothIsOn"), object: nil)
            default:
                break
            }
        }
    }
}
