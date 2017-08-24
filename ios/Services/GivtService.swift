//
//  GivtService.swift
//  ios
//
//  Created by Lennie Stockman on 22/08/2017.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

final class GivtService: NSObject, GivtServiceProtocol, CBCentralManagerDelegate {
    static let sharedInstance = GivtService()
    
    private var amount: Decimal!
    private var bestBeacon: BestBeacon?
    var bluetoothEnabled: Bool? {
        get {
            return centralManager != nil && centralManager.state == .poweredOn
        }
    }
    
    private var rssiTreshold: Int = -68
    
    var isScanning: Bool?
    
    var centralManager: CBCentralManager!
    //var peripheral: CBPeripheral
    weak var onGivtProcessed: GivtProcessedProtocol?
    
    private override init() {
        super.init()
        print("started")
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global())
    }
    
    func setAmount(amount: Decimal) {
        self.amount = amount
    }
    
    func startScanning() {
        isScanning = true
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func stopScanning() {
        if(isScanning)!{
            isScanning = false
            centralManager.stopScan()
        }
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        switch (central.state) {
        case .poweredOff:
            print("CBCentralManagerState.PoweredOff")
        case .unauthorized:
            print("CBCentralManagerState.Unauthorized")
            break
        case .unknown:
            print("CBCentralManagerState.Unknown")
            break
        case .poweredOn:
            print("CBCentralManagerState.PoweredOn")
            startScanning()
        case .resetting:
            print("CBCentralManagerState.Resetting")
        case CBManagerState.unsupported:
            print("CBCentralManagerState.Unsupported")
            break
        }
}
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let feaa = advertisementData[CBAdvertisementDataServiceDataKey] as! NSMutableDictionary? {
            let x = feaa.object(forKey: CBUUID(string: "FEAA"))
            //print(feaa)
         //   print("beacon found with rssi: ", RSSI)
            if(x != nil){
                print(x!)
                let y = String.init(describing: x!)
                //61f7
                let antennaType = String(describing: x).substring(5..<14)
                print(y.substring(5..<14))
                if(y.substring(5..<14) == "61f7 ed01"){
                    //hoera
                    print("beacon found with rssi: ", RSSI)
                    let antennaID = String(format: "%@.%@", y.substring(5..<27).replacingOccurrences(of: " ", with: ""), y.substring(27..<41).replacingOccurrences(of: " ", with: ""))
                    print(antennaID)
                    beaconDetected(antennaID: antennaID, rssi: RSSI, beaconType: 0, batteryLevel: 100)
                    //sendPostRequest(antennaID: antennaID)
                }
            }
        } else {
            //print("nill")
        }
    }
    
    private func beaconDetected(antennaID: String, rssi: NSNumber, beaconType: Int8, batteryLevel: Int8) {
        stopScanning()
        
        if(rssi != 0x7f){
            if(((bestBeacon?.beaconId) != nil) && bestBeacon?.rssi == 0){
                bestBeacon?.beaconId = antennaID
                bestBeacon?.rssi = rssi
                bestBeacon?.organisation = antennaID.substring(to: antennaID.index(of: ".")!)
            } else if(((bestBeacon?.beaconId) != nil) && (bestBeacon?.rssi?.intValue)! < rssi.intValue) {
                bestBeacon?.beaconId = antennaID
                bestBeacon?.rssi = rssi
                bestBeacon?.organisation = antennaID.substring(to: antennaID.index(of: ".")!)
            }
            
            if(rssi.intValue > rssiTreshold){
                let amount: Decimal = 4.50
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS0"
                let date = df.string(from: Date())
                print(date)
                let collectId = "1"
                give(antennaID: antennaID, amount: amount, date: date, collectId: collectId)
                return
            }
        }
        
        startScanning()
    }
    
    private func give(antennaID: String, amount: Decimal, date: String, collectId: String) {
     
        let parameters = ["UserId": "70b10bd0-320e-479a-8551-a6ea69b560e6",
                          "BeaconId": antennaID,
                          "Amount": amount,
                          "Timestamp": date] as [String : Any]
        sendPostRequest(parameters: parameters) { status in
            self.onGivtProcessed?.onGivtProcessed(status: status)
        }
    }
    
    func sendPostRequest(parameters: [String: Any], completionHandler: @escaping (Bool) -> ()) {
        guard let url = URL(string: "https://givtapidebug.azurewebsites.net/api/Givts") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            return
        }
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            //self.showWebsite()
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 201 {           // check for http errors
                print("statusCode should be 201, but is \(httpStatus.statusCode)")
                // print("response = \(response)")
                completionHandler(false)
                return
            }
            
            var httpStatus = response as? HTTPURLResponse
            if(httpStatus?.statusCode == 201){
                print("posted givt to the server")
                completionHandler(true)
                return
            }
            
            let responseString = String(data: data!, encoding: .utf8)
            print("responseString = \(responseString)")
            do
            {
                let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                let currentData = parsedData
                print(parsedData["status code"]!)
                
                return
            } catch let error as NSError {
                print(error)
                return
            }
            
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
            }.resume()
    }
    
}

protocol BeaconDetectedDelegate: class {
    func onBeaconDetected(antennaID: String, rssi: NSNumber, beaconType: Int8, batteryLevel: Int8)
}

protocol GivtProcessedProtocol: class {
    func onGivtProcessed(status: Bool)
}

class BestBeacon {
    var beaconId: String?
    var rssi: NSNumber?
    var organisation: String?
    
    init(b: String, r: NSNumber, o: String) {
        beaconId = b
        rssi = r
        organisation = o
    }
    
    
}
