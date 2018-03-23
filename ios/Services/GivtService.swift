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

final class GivtService: NSObject, CBCentralManagerDelegate {
    static let shared = GivtService()
    private var log = LogService.shared
    let reachability = Reachability()
    
    static let FEAA = CBUUID.init(string: "FEAA")
    
    private var client = APIClient.shared
    private var amount: Decimal!
    private var amounts = [Decimal]()
    private let scanLock = NSRecursiveLock()
    
    var scannedPeripherals: [String: Int] = [String: Int]()
    
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
    
    func getOrgName(orgNameSpace: String) -> String? {
        var orgName = orgBeaconList.filter { (organisation) -> Bool in
            return organisation["EddyNameSpace"] as? String == orgNameSpace
        }
        return orgName.first?["OrgName"] as? String
    }
    
    var lastGivtOrg: String {
        get {
            if bestBeacon.organisation != nil {
                for organisationBeacon in orgBeaconList {
                    if let org = organisationBeacon["EddyNameSpace"] as? String, let orgName = organisationBeacon["OrgName"] as? String, org == bestBeacon.organisation {
                        return orgName
                    }
                }   
            }
            return ""
        }
    }
    
    var beaconListLastChanged: String? {
        get {
            let list = UserDefaults.standard.orgBeaconList as! [String: Any]
            if let lastChanged = list["LastChanged"] as? String {
                return lastChanged
            }
            self.log.warning(message: "No lastchanged found in beacon list")
            return nil 
        }
    }
    
    private var rssiTreshold: Int = -68
    var isScanning: Bool = false
    
    var centralManager: CBCentralManager!
    weak var delegate: GivtProcessedProtocol?
    
    private override init() {
        super.init()
        resume()
        
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global(qos: .userInitiated), options: [CBCentralManagerOptionShowPowerAlertKey:false])
        
        NotificationCenter.default.addObserver(self, selector: #selector(internetChanged), name: ReachabilityChangedNotification, object: reachability)
        do {
            try reachability?.startNotifier()
        } catch {
            print("could not start notifier")
        }
    }
    
    public func resume() {
        getBeaconsFromOrganisation { (status) in
            print(status)
        }
        
        getPublicMeta()
    }
    
    @objc func internetChanged(note: Notification){
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            log.info(message: "App got connected")
            for (index, element) in UserDefaults.standard.offlineGivts.enumerated().reversed() {
                log.info(message: "Started processing chached Givts")
                giveInBackground(transactions: [element])
                UserDefaults.standard.offlineGivts.remove(at: index)
                print(UserDefaults.standard.offlineGivts)
            }
        } else {
            log.info(message: "App got disconnected")
        }
    }
    
    func setAmount(amount: Decimal) {
        self.amount = amount
    }
    
    func setAmounts(amounts: [Decimal]) {
        self.amounts = amounts
    }
    
    func startScanning() {
        self.scannedPeripherals.removeAll()
        scanLock.lock()
        if (!isScanning)
        {
            log.info(message: "Started scanning")
            isScanning = true
            centralManager.scanForPeripherals(withServices: [GivtService.FEAA], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            DispatchQueue.main.async {
                UIApplication.shared.isIdleTimerDisabled = true
            }
        }
        scanLock.unlock()
    }
    
    func stopScanning() {
        scanLock.lock()
        if(isScanning){
            log.info(message: "Stopped scanning")
            isScanning = false
            centralManager.stopScan()
            DispatchQueue.main.async {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
        scanLock.unlock()
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
                let y = String.init(describing: x!)

                if(y.substring(5..<14) == "61f7 ed01" || y.substring(5..<14) == "61f7 ed02" || y.substring(5..<14) == "61f7 ed03") {
                    let antennaID = String(format: "%@.%@", y.substring(5..<27).replacingOccurrences(of: " ", with: ""), y.substring(27..<41).replacingOccurrences(of: " ", with: ""))
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
            bv < 2500 ? self.log.warning(message: msg) : self.log.info(message: msg)
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
                bestBeacon.organisation = organisation
            } else {
                /* new beacon */
                bestBeacon.beaconId = antennaID
                bestBeacon.rssi = rssi
                bestBeacon.organisation = organisation
            }
            
            if(rssi.intValue > rssiTreshold) {
                scanLock.lock()
                if (isScanning) {
                    self.stopScanning()
                    DispatchQueue.main.async {
                        self.give(antennaID: antennaID)
                    }
                }
                scanLock.unlock()
            }
        }
    }
    
    func give(antennaID: String) {
        LoginManager.shared.userClaim = .give //set to give so we show popup if user is still temp
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS0"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.locale = Locale(identifier: "en_US_POSIX") as Locale!
        let date = df.string(from: Date())
        print(date)
        var transactions = [Transaction]()
        for (index, value) in amounts.enumerated() {
            if value >= 0.50 {
                print(value)
                let newTransaction = Transaction(amount: value, beaconId: antennaID, collectId: String(index + 1), timeStamp: date, userId: (UserDefaults.standard.userExt?.guid)!)
                transactions.append(newTransaction)
            }
        }
        
        giveInBackground(transactions: transactions)
        self.delegate?.onGivtProcessed(transactions: transactions)
        
        let deadlineTime = DispatchTime.now() + 0.20
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            AudioServicesPlayAlertSound(1520)
        }
        
        bestBeacon = BestBeacon()
    }
    
    func giveQR(scanResult: String, completionHandler: @escaping (Bool) -> Void) {
        let queryString = "https://www.givtapp.net/download?code="
        if scanResult.index(of: queryString) != nil {
            let identifierEncoded = String(scanResult[queryString.endIndex...])
            if let decoded = identifierEncoded.base64Decoded() {
                /* mimic bestbeacon */
                bestBeacon.beaconId = decoded
                if let idx = decoded.index(of: ".") {
                    bestBeacon.organisation = String(decoded[..<idx])
                } else {
                    bestBeacon.organisation = decoded
                }
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
            bestBeacon.organisation = String(antennaId[..<idx])
        } else {
            bestBeacon.organisation = antennaId
        }
        give(antennaID: antennaId)
    }
    
    
    private func cacheGivt(transactions: [Transaction]){
        
        for tr in transactions {
            self.log.info(message: "Cached givt")
            UserDefaults.standard.offlineGivts.append(tr)
        }
        
        print(UserDefaults.standard.offlineGivts)
        for t in UserDefaults.standard.offlineGivts {
            print(t.amount)
        }
    }
    
    private func tryGive(transactions: [Transaction], trycount: UInt = 0) {
        var object = ["Transactions": []]
        for transaction in transactions {
            object["Transactions"]?.append(transaction.convertToDictionary())
        }
        do {
            if trycount < 3 {
                try client.post(url: "/api/Givts/Multiple", data: object) { (res) in
                    if let res = res {
                        if res.basicStatus == .ok {
                            self.log.info(message: "Posted Givt to the server")
                        } else if res.status == .expectationFailed {
                            self.log.warning(message: "Givt was not sent to server. Gave between 30s?")
                        } else {
                            self.tryGive(transactions: transactions, trycount: trycount+1)
                        }
                    } else {
                        self.cacheGivt(transactions: transactions)
                    }
                }
            } else {
                self.log.error(message: "Didn't get response from server! Caching givt...")
                self.cacheGivt(transactions: transactions)
            }
        } catch {
            self.log.error(message: "Unknown error : \(error)")
        }
    }
    
    func giveInBackground(transactions: [Transaction])
    {
        let bgTask = UIApplication.shared.beginBackgroundTask {
            //task will end by itself
        }
        self.tryGive(transactions: transactions, trycount: 0)
        UIApplication.shared.endBackgroundTask(bgTask)
    }
    
    func getGivts(callback: @escaping ([HistoryTransaction]) -> Void) {
        client.get(url: "/api/Givts", data: [:]) { (response) in
            var models: [HistoryTransaction] = []
            if let response = response, let data = response.data, response.statusCode == 202 {
                do
                {
                    let parsedData = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
                    for x in parsedData {
                        models.append(HistoryTransaction(dictionary: x as Dictionary<String, Any>)!)
                    }
                    callback(models)
                } catch {
                    callback(models)
                }
            } else {
                callback(models)
            }
        }
    }
    
    func getPublicMeta() {
        if UserDefaults.standard.userExt == nil || UserDefaults.standard.showedLastYearTaxOverview == true {
            return
        }
        let year = Date().getYear() - 1 //get the previous year
        client.get(url: "/api/v2/users/\(UserDefaults.standard.userExt!.guid)/givts/public-meta?year=\(year)", data: [:]) { (response) in
            if let response = response {
                if response.basicStatus == .ok {
                    do
                    {
                        let parsedData = try JSONSerialization.jsonObject(with: response.data!) as! [String: Any]
                        if let parsedBool = parsedData["HasDeductableGivts"] as? Bool {
                            UserDefaults.standard.hasGivtsInPreviousYear = parsedBool
                        } else {
                            UserDefaults.standard.hasGivtsInPreviousYear = false
                        }
                        print("Has givts in \(year):", UserDefaults.standard.hasGivtsInPreviousYear)
                    } catch {
                        UserDefaults.standard.hasGivtsInPreviousYear = false //for the sake of it
                    }
                } else {
                    UserDefaults.standard.hasGivtsInPreviousYear = false //for the sake of it
                }
            } else {
                UserDefaults.standard.hasGivtsInPreviousYear = false //for the sake of it
            }
        }
    }
    
    func sendGivtOverview(callback: @escaping (Bool) -> Void) {
        client.get(url: "/api/v2/users/\(UserDefaults.standard.userExt!.guid)/givts/mail-report?year=\(Date().getYear()-1)", data: [:]) { (response) in
            if let response = response {
                if response.basicStatus == .ok {
                    callback(true)
                } else {
                    callback(false)
                }
            } else {
                callback(false)
            }
            
        }
    }
    
    func deleteTransactions(transactionsIds: [Int], completion: @escaping (Bool) -> Void) {
        
    }
    
    func getBeaconsFromOrganisation(completionHandler: @escaping (Bool) -> Void) {
        
        if let userExt = UserDefaults.standard.userExt, !userExt.guid.isEmpty() {
            var data = ["Guid" : userExt.guid]
            // add &dtLastChanged when beaconList is filled
            if UserDefaults.standard.orgBeaconList != nil {
                if let date = beaconListLastChanged {
                    data["dtLastUpdated"] = date
                }
            }
            client.get(url: "/api/Organisation/BeaconList", data: data, callback: { (response) in
                if let response = response, let data = response.data {
                    if response.statusCode == 200 {
                        do {
                            let parsedData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                            UserDefaults.standard.orgBeaconList = parsedData as NSDictionary
                            print("updated beacon list")
                            completionHandler(true)
                        } catch let err as NSError {
                            completionHandler(false)
                            print(err)
                        }
                    } else if response.statusCode == 204 {
                        completionHandler(false)
                        print("list up to date")
                    } else {
                        completionHandler(false)
                        print("unknow statuscode")
                    }
                } else {
                    print("no response from server?")
                    completionHandler(false)
                }
            })
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
