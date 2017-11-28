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
import AudioToolbox

final class GivtService: NSObject, GivtServiceProtocol, CBCentralManagerDelegate {
    static let shared = GivtService()
     private var _baseUrl = "https://givtapidebug.azurewebsites.net"
    let reachability = Reachability()
    
    private var amount: Decimal!
    private var amounts = [Decimal]()

    var getBestBeacon: BestBeacon {
        get {
            return bestBeacon
        }
    }
    private var bestBeacon: BestBeacon = BestBeacon()
    var bluetoothEnabled: Bool {
        get {
            return centralManager != nil && centralManager.state == .poweredOn
        }
    }
    
    var orgBeaconList: [NSDictionary] {
        if let list = UserDefaults.standard.orgBeaconList as? [String: Any] {
            if let temp = list["OrgBeacons"] as? [NSDictionary] {
                return temp
            }
            
        }
        return [NSDictionary]()
    }
    
    var lastGivtOrg: String {
        get {
            if let orgId = bestBeacon.organisation {
                for organisationBeacon in orgBeaconList {
                    if let org = organisationBeacon["EddyNameSpace"] as? String, let orgName = organisationBeacon["OrgName"] as? String, org == bestBeacon.organisation {
                        return orgName
                    }
                }   
            }
            return ""
        }
    }
    
    var beaconListLastChanged: Date {
        get {
            let list = UserDefaults.standard.orgBeaconList as! [String: Any]
            let lastChanged = list["LastChanged"] as! String
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
            let date = dateFormatter.date(from: lastChanged)!
            return date
        }
    }

    private var rssiTreshold: Int = -68
    var isScanning: Bool = false

    var centralManager: CBCentralManager!
    weak var onGivtProcessed: GivtProcessedProtocol?
    
    private override init() {
        super.init()
        getBeaconsFromOrganisation { (status) in
            print(status)
        }
        
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global(), options: [CBCentralManagerOptionShowPowerAlertKey:false])

        NotificationCenter.default.addObserver(self, selector: #selector(internetChanged), name: ReachabilityChangedNotification, object: reachability)
        do {
            try reachability?.startNotifier()
        } catch {
            print("could not start notifier")
        }
    }
    
    @objc func internetChanged(note: Notification){
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            for (index, element) in UserDefaults.standard.offlineGivts.enumerated().reversed() {
                sendPostRequest(transactions: [element])
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
    
    func setAmounts(amounts: [Decimal]) {
        self.amounts = amounts
    }
    
    func startScanning() {
        isScanning = true
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    func stopScanning() {
        if(isScanning){
            isScanning = false
            centralManager.stopScan()
        }
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        if #available(iOS 10.0, *) {
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
                NotificationCenter.default.post(name: Notification.Name("BluetoothIsOn"), object: nil)
            case .resetting:
                print("CBCentralManagerState.Resetting")
            case CBManagerState.unsupported:
                print("CBCentralManagerState.Unsupported")
                break
            }
        } else {
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
                NotificationCenter.default.post(name: Notification.Name("BluetoothIsOn"), object: nil)
            case .resetting:
                print("CBCentralManagerState.Resetting")
            default:
                break
            }
        }
}
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let feaa = advertisementData[CBAdvertisementDataServiceDataKey] as! NSMutableDictionary? {
            let x = feaa.object(forKey: CBUUID(string: "FEAA"))
            if(x != nil){
                //print(x!)
                let y = String.init(describing: x!)
                //61f7
                _ = String(describing: x).substring(5..<14)
                print(y.substring(5..<14))
                if(y.substring(5..<14) == "61f7 ed01"){
                    //print("beacon found with rssi: ", RSSI)
                    let antennaID = String(format: "%@.%@", y.substring(5..<27).replacingOccurrences(of: " ", with: ""), y.substring(27..<41).replacingOccurrences(of: " ", with: ""))
                                            //print(antennaID)
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
            var organisation = antennaID
            if let idx = antennaID.index(of: ".") {
                organisation = antennaID.substring(to: idx)
            }
            
            if let _ = bestBeacon.beaconId, let bestBeaconRssi = bestBeacon.rssi {
                /* beacon exists */
                if bestBeaconRssi.intValue < rssi.intValue {
                    bestBeacon.beaconId = antennaID
                    bestBeacon.rssi = rssi
                    bestBeacon.organisation = organisation
                }
            } else {
                /* new beacon */
                bestBeacon.beaconId = antennaID
                bestBeacon.rssi = rssi
                bestBeacon.organisation = organisation
            }
            
            if(rssi.intValue > rssiTreshold){
                give(antennaID: antennaID)
                return
            }
 
        }
        
        startScanning()
    }
    
    func give(antennaID: String) {
        LoginManager.shared.userClaim = .give //set to give so we show popup if user is still temp
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS0"
        df.timeZone = TimeZone(abbreviation: "UTC")
        let date = df.string(from: Date())
        print(date)
        let collectId = "1"
        var transactions = [Transaction]()
        for (index, value) in amounts.enumerated() {
            if value >= 0.50 {
                print(value)
                var newTransaction = Transaction(amount: value, beaconId: antennaID, collectId: String(index + 1), timeStamp: date, userId: (UserDefaults.standard.userExt?.guid)!)
                transactions.append(newTransaction)
            }
        }
        
        sendPostRequest(transactions: transactions)
        //todo: clear self.amountss
        self.onGivtProcessed?.onGivtProcessed(transactions: transactions)
        AudioServicesPlayAlertSound(1520)
    }
    
    func giveQR(scanResult: String, completionHandler: @escaping (Bool) -> Void) {
        let queryString = "https://www.givtapp.net/download?code="
        if let startPosition = scanResult.index(of: queryString) {
            let identifierEncoded = scanResult.substring(from: queryString.endIndex)
            if let decoded = identifierEncoded.base64Decoded() {
                /* mimic bestbeacon */
                bestBeacon.beaconId = decoded
                if let idx = decoded.index(of: ".") {
                    bestBeacon.organisation = decoded.substring(to: idx)
                } else {
                    bestBeacon.organisation = decoded
                }
                bestBeacon.rssi = 0
                give(antennaID: decoded)
                completionHandler(true)
            } else {
                //todo: log messed up base 64
                completionHandler(false)
            }
        } else {
            //todo log result: not our qr code
            completionHandler(false)
        }
    }
    
    func giveManually(antennaId: String) {
        bestBeacon.beaconId = antennaId
        if let idx = antennaId.index(of: ".") {
            bestBeacon.organisation = antennaId.substring(to: idx)
        } else {
            bestBeacon.organisation = antennaId
        }
        bestBeacon.rssi = 0
        give(antennaID: antennaId)
    }

    
    private func cacheGivt(transactions: [Transaction]){
        for tr in transactions {
            UserDefaults.standard.offlineGivts.append(tr)
        }
        
        print(UserDefaults.standard.offlineGivts)
        for t in UserDefaults.standard.offlineGivts {
            print(t.amount)
        }
    }
    
    func sendPostRequest(transactions: [Transaction]) {
        guard let url = URL(string: "https://givtapidebug.azurewebsites.net/api/Givts/Multiple") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        var object = ["Transactions": []]
        for transaction in transactions {
            object["Transactions"]?.append(transaction.convertToDictionary())
        }
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            return
        }
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        session.dataTask(with: request)
            { (data, response, error) in
            
                if error != nil {
                    self.cacheGivt(transactions: transactions)
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 201 {
                    return
                } else {
                    //server code is niet in orde: gegeven binnen de 30s?
                    return
                }
            }
        .resume()
    }
    
    func getBeaconsFromOrganisation(completionHandler: @escaping (Bool) -> Void) {
        if let userExt = UserDefaults.standard.userExt, !userExt.guid.isEmpty() {
            var qString = "Guid=" + userExt.guid
            
            // add &dtLastChanged when beaconList is filled
            if let list = UserDefaults.standard.orgBeaconList {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
                let dateString = dateFormatter.string(from: beaconListLastChanged)
                qString += "&dtLastUpdated=" + dateString
            }
  
            var request = URLRequest(url: URL(string: _baseUrl + "/api/Organisation/BeaconList" + "?" + qString)!)
            request.httpMethod = "GET"
            request.setValue("Bearer " + UserDefaults.standard.bearerToken, forHTTPHeaderField: "Authorization")
            let urlSession = URLSession.shared
            _ = urlSession.dataTask(with: request) { data, response, error -> Void in
                if error != nil {
                    completionHandler(false)
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    if httpStatus.statusCode == 204 {

                    }
                    completionHandler(false)
                    return
                }
                
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                    UserDefaults.standard.orgBeaconList = parsedData as NSDictionary
                    completionHandler(true)
                } catch let err as NSError {
                    completionHandler(false)
                    return
                }
                
                }.resume()
            
        }

    }
    
}

protocol GivtProcessedProtocol: class {
    func onGivtProcessed(transactions: [Transaction])
}

class BestBeacon {
    var beaconId: String?
    var rssi: NSNumber?
    var organisation: String?
    
    init(_ b: String? = nil,_ r: NSNumber? = nil,_ o: String? = nil) {
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
