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
import Reachability
import AudioToolbox

final class GivtService: NSObject, GivtServiceProtocol, CBCentralManagerDelegate {
    static let sharedInstance = GivtService()
    
    let reachability = Reachability()
    
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
    weak var onGivtProcessed: GivtProcessedProtocol?
    
    private override init() {
        super.init()
        print("started")
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global(), options: [CBCentralManagerOptionShowPowerAlertKey:false])

        NotificationCenter.default.addObserver(self, selector: #selector(internetChanged), name: ReachabilityChangedNotification, object: reachability)
        do {
            try reachability?.startNotifier()
        } catch {
            print("could not start notifier")
        }
    }
    
    func internetChanged(note: Notification){
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            for (index, element) in UserDefaults.standard.offlineGivts.enumerated().reversed() {
                give(transaction: element, wasOfflineGivt: true)
                UserDefaults.standard.offlineGivts.remove(at: index)
                print(UserDefaults.standard.offlineGivts)
            }
        } else {
            print("not reachable")
        }
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
            NotificationCenter.default.post(name: Notification.Name("BluetoothIsOff"), object: nil)
        case .unauthorized:
            print("CBCentralManagerState.Unauthorized")
            break
        case .unknown:
            print("CBCentralManagerState.Unknown")
            break
        case .poweredOn:
            print("CBCentralManagerState.PoweredOn")
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
            if(x != nil){
                print(x!)
                let y = String.init(describing: x!)
                //61f7
                _ = String(describing: x).substring(5..<14)
                print(y.substring(5..<14))
                if(y.substring(5..<14) == "61f7 ed01"){
                    print("beacon found with rssi: ", RSSI)
                    let antennaID = String(format: "%@.%@", y.substring(5..<27).replacingOccurrences(of: " ", with: ""), y.substring(27..<41).replacingOccurrences(of: " ", with: ""))
                                            print(antennaID)
                    beaconDetected(antennaID: antennaID, rssi: RSSI, beaconType: 0, batteryLevel: 100)
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
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS0"
                df.timeZone = TimeZone(abbreviation: "UTC")
                let date = df.string(from: Date())
                print(date)
                let collectId = "1"
                let ts = Transaction(amount: self.amount, beaconId: antennaID, collectId: collectId, timeStamp: date, userId: "70b10bd0-320e-479a-8551-a6ea69b560e6")
                give(transaction: ts)
                return
            }
        }
        
        startScanning()
    }
    
    private func give(transaction: Transaction, wasOfflineGivt: Bool = false) {
        sendPostRequest(transaction: transaction) { status in
            if(!wasOfflineGivt) {
                self.onGivtProcessed?.onGivtProcessed(transaction: transaction, status: status)
                AudioServicesPlayAlertSound(1520)
            }
        }
        return
    }
    
    private func cacheGivt(transaction: Transaction){
        UserDefaults.standard.offlineGivts.append(transaction)
        print(UserDefaults.standard.offlineGivts)
        for t in UserDefaults.standard.offlineGivts {
            print(t.amount)
        }
    }
    
    func sendPostRequest(transaction: Transaction, completionHandler: @escaping (Bool) -> ()) {
        guard let url = URL(string: "https://givtapidebug.azurewebsites.net/api/Givts") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: transaction.convertToDictionary(), options: JSONSerialization.WritingOptions.prettyPrinted) else {
            return
        }
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        session.dataTask(with: request)
            { (data, response, error) in
            
                if error != nil {
                    self.cacheGivt(transaction: transaction)
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 201 {
                    print("posted givt to the server")
                    completionHandler(true)
                    return
                } else {
                    //server code is niet in orde: gegeven binnen de 30s?
                    print(response ?? "")
                    completionHandler(false)
                    return
                }
            }
        .resume()
    }
    
}

protocol GivtProcessedProtocol: class {
    func onGivtProcessed(transaction: Transaction, status: Bool)
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

class Transaction:NSObject, NSCoding {
    var amount: Decimal
    var beaconId: String
    var collectId: String
    var timeStamp: String
    var userId: String
    
    init(amount: Decimal, beaconId: String, collectId: String, timeStamp: String, userId: String) {
        self.amount = amount
        self.beaconId = beaconId
        self.collectId = collectId
        self.userId = userId
        self.timeStamp = timeStamp
    }
    convenience required init?(coder aDecoder: NSCoder) {
        guard
            let amount = aDecoder.decodeObject(forKey: "amount") as? Decimal,
            let beaconId    = aDecoder.decodeObject(forKey: "beaconId")    as? String,
            let collectId    = aDecoder.decodeObject(forKey: "collectId")    as? String,
            let timeStamp    = aDecoder.decodeObject(forKey: "timeStamp")    as? String,
            let userId    = aDecoder.decodeObject(forKey: "userId")    as? String
            else {
                return nil
        }
        self.init(amount: amount, beaconId: beaconId, collectId: collectId, timeStamp: timeStamp, userId: userId)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(amount, forKey: "amount")
        aCoder.encode(beaconId, forKey: "beaconId")
        aCoder.encode(collectId, forKey: "collectId")
        aCoder.encode(timeStamp, forKey: "timeStamp")
        aCoder.encode(userId, forKey: "userId")
    }
    
    func convertToDictionary() -> Dictionary<String, Any> {
        return [
            "Amount"   : self.amount,
            "BeaconId" : self.beaconId,
            "UserId"    : self.userId,
            "CollectId" : self.collectId,
            "Timestamp"     : self.timeStamp
                ]
        }
    
}
