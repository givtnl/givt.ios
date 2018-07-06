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
import SwiftClient
import CoreLocation
import SwiftCron

struct BeaconList: Codable {
    var OrgBeacons: [OrgBeacon]
    var LastChanged: Date
}

struct OrgBeacon: Codable {
    let EddyNameSpace: String
    let OrgName: String
    let Celebrations: Bool
    let Locations: [OrgBeaconLocation]
    let MultiUseAllocations: [MultiUseAllocations]?
}

struct OrgBeaconLocation: Codable {
    let Name: String
    let Latitude: Double
    let Longitude: Double
    let Radius: Int
    let BeaconId: String
    let dtBegin: Date
    let dtEnd: Date
}

struct MultiUseAllocations: Codable {
    let Name: String
    let dtBeginCron: String
    let dtEndCron: String
}

final class GivtService: NSObject {
    private let beaconService = BeaconService()
    static let shared = GivtService()
    private var log = LogService.shared
    private var locationService = LocationService.instance
    let reachability = Reachability()
    
    static let FEAA = CBUUID.init(string: "FEAA")
    
    private var client = APIClient.shared
    private var amount: Decimal!
    private var amounts = [Decimal]()
    private var scanLock = NSRecursiveLock()
    
    var customReturnAppScheme: String?
    
    var bestBeacon: BestBeacon?
    
    var isBluetoothEnabled: Bool {
        get {
            return beaconService.isBluetoothEnabled
        }
    }
    
    var orgBeaconList: [OrgBeacon]? {
        return UserDefaults.standard.orgBeaconListV2?.OrgBeacons
    }
    
    func getOrganisationName(organisationNameSpace: String) -> String? {
        return orgBeaconList?.first(where: { (orgBeacon) -> Bool in
            return orgBeacon.EddyNameSpace == organisationNameSpace
        })?.OrgName
    }
    
    func isCelebration(orgNameSpace: String) -> Bool {
        return orgBeaconList?.first(where: { (orgBeacon) -> Bool in
            return orgBeacon.EddyNameSpace == orgNameSpace
        })?.Celebrations ?? false
    }
    
    func canShare(id: String) -> Bool {
        return !id.substring(16..<19).matches("c[0-9]|d[be]")
    }
    
    func determineOrganisationName(namespace: String) -> String? {
        guard let organisation = orgBeaconList?.first(where: { (orgBeacon) -> Bool in
            return orgBeacon.EddyNameSpace == namespace
        }) else { return nil }
        
        if let ma = organisation.MultiUseAllocations, ma.count > 0 {
            for m in ma {
                let date = Date()
                if let begin = CronExpression(cronString: m.dtBeginCron)?.getNextRunDate(date), let end = CronExpression(cronString: m.dtEndCron)?.getNextRunDate(date) {
                    if end < begin {
                        self.log.info(message: "Could succesfully identify CRON-Allocation-Beacon")
                        return m.Name
                    }
                }
            }
            self.log.warning(message: "Could NOT identify CRON-Allocation-Beacon")
        }
        return organisation.OrgName
    }
    
    var beaconListLastChanged: String? {
        get {
            return UserDefaults.standard.orgBeaconListV2?.LastChanged.toString("yyyy-MM-dd'T'HH:mm:ss.SSS")
        }
    }
    
    private var _shouldNotify: Bool = false
    weak var delegate: GivtProcessedProtocol?
    
    private override init() {
        super.init()
        resume()
        
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
    
    func startScanning(scanMode: ScanMode) {
        beaconService.delegate = self
        beaconService.startScanning(mode: scanMode)
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    func stopScanning() {
        beaconService.delegate = nil
        beaconService.stopScanning()
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    func startLookingForGivtLocations() {
        locationService.delegate = self
        startScanning(scanMode: .far)
        locationService.startLookingForLocation()
    }
    
    func stopLookingForGivtLocations() {
        locationService.delegate = nil
        stopScanning()
        locationService.stopLookingForLocation()
    }

    func give(antennaID: String, organisationName: String?) {
        LoginManager.shared.userClaim = .give //set to give so we show popup if user is still temp
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS0"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.locale = Locale(identifier: "en_US_POSIX")
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
        self.delegate?.onGivtProcessed(transactions: transactions, organisationName: organisationName, canShare: canShare(id: antennaID))
        
        let deadlineTime = DispatchTime.now() + 0.20
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            AudioServicesPlayAlertSound(1520)
        }
    }
    
    func giveQR(scanResult: String, completionHandler: @escaping (Bool) -> Void) {
        let queryString = "https://www.givtapp.net/download?code="
        if scanResult.index(of: queryString) != nil {
            let identifierEncoded = String(scanResult[queryString.endIndex...])
            if let decoded = identifierEncoded.base64Decoded() {
                let bestBeacon = BestBeacon()
                /* mimic bestbeacon */
                bestBeacon.beaconId = decoded
                if let idx = decoded.index(of: ".") {
                    bestBeacon.namespace = String(decoded[..<idx])
                } else {
                    bestBeacon.namespace = decoded
                }
                //bepaal naam
                give(antennaID: decoded, organisationName: self.getOrganisationName(organisationNameSpace: bestBeacon.namespace!))
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
    
    func giveManually(antennaId: String, afterGivt: ((Int, [Transaction], String) -> ())? = nil) {
        let bestBeacon = BestBeacon()
        bestBeacon.beaconId = antennaId
        if let idx = antennaId.index(of: ".") {
            bestBeacon.namespace = String(antennaId[..<idx])
        } else {
            bestBeacon.namespace = antennaId
        }
        
        let shouldCelebrate = isCelebration(orgNameSpace: bestBeacon.namespace!)
        print("should celebrate \(shouldCelebrate)")
        if let afterGivt = afterGivt, shouldCelebrate {
            LoginManager.shared.userClaim = .give //set to give so we show popup if user is still temp
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS0"
            df.timeZone = TimeZone(abbreviation: "UTC")
            df.locale = Locale(identifier: "en_US_POSIX")
            let date = df.string(from: Date())
            print(date)
            var transactions = [Transaction]()
            for (index, value) in amounts.enumerated() {
                if value >= 0.50 {
                    print(value)
                    let newTransaction = Transaction(amount: value, beaconId: bestBeacon.beaconId!, collectId: String(index + 1), timeStamp: date, userId: (UserDefaults.standard.userExt?.guid)!)
                    transactions.append(newTransaction)
                }
            }
            
            giveCelebrate(transactions: transactions, afterGivt: { seconds in
                if seconds > 0 {
                    afterGivt(seconds, transactions, self.getOrganisationName(organisationNameSpace: bestBeacon.namespace!)!)
                } else {
                    self.delegate?.onGivtProcessed(transactions: transactions,
                                                   organisationName: self.getOrganisationName(organisationNameSpace: bestBeacon.namespace!),
                                                   canShare: self.canShare(id: bestBeacon.beaconId!))
                }
            })
        } else {
            give(antennaID: bestBeacon.beaconId!, organisationName: self.getOrganisationName(organisationNameSpace: bestBeacon.namespace!))
        }
        
    }
    
    private func giveCelebrate(transactions: [Transaction], afterGivt: @escaping (Int) -> ()) {
        var object = ["Transactions": []]
        for transaction in transactions {
            object["Transactions"]?.append(transaction.convertToDictionary())
        }
        do {
            try client.post(url: "/api/Givts/Multiple", data: object) { (res) in
                if let res = res {
                    if res.basicStatus == .ok {
                        self.log.info(message: "Posted Givt to the server")
                        if let data = res.data {
                            do {
                                let parsedData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                                if let secondsToCelebration = parsedData["SecondsToCelebration"] as? Int {
                                    if secondsToCelebration > 0 {
                                        afterGivt(secondsToCelebration)
                                        return
                                    }
                                }
                                afterGivt(-1)
                                print(parsedData)
                            } catch {
                                afterGivt(-1)
                            }
                        }
                        afterGivt(-1)
                    } else {
                        afterGivt(-1)
                    }
                } else {
                    //no response
                    afterGivt(-1)
                    self.cacheGivt(transactions: transactions)
                }
            }
        } catch {
            afterGivt(-1)
            self.log.error(message: "Unknown error : \(error)")
        }
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
                            if let data = res.data {
                                do {
                                    let parsedData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                                    if let secondsToCelebration = parsedData["SecondsToCelebration"] as? Int {
                                        if secondsToCelebration > 0 {
                                            print(secondsToCelebration)
                                        }
                                    }
                                    print(parsedData)
                                } catch {
                                    
                                }
                            }
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
                    UserDefaults.standard.showedLastYearTaxOverview = true
                    callback(true)
                } else {
                    callback(false)
                }
            } else {
                callback(false)
            }
            
        }
    }
    
    func delete(transactionsIds: [Int], completion: @escaping (Response?) -> Void) {
        client.delete(url: "/api/v2/Givts/Multiple", data: transactionsIds) { (response) in
            completion(response)
        }
    }

    func getBeaconsFromOrganisation(completionHandler: @escaping (Bool) -> Void) {
        
        if let userExt = UserDefaults.standard.userExt, !userExt.guid.isEmpty() {
            var data = ["Guid" : userExt.guid]
            client.get(url: "/api/v2/collectgroups/applist", data: data, callback: { (response) in
                if let response = response, let data = response.data {
                    if response.statusCode == 200 {
                        do {
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .custom({ (date) -> Date in
                                let container = try date.singleValueContainer()
                                var dateStr = try container.decode(String.self)
                                dateStr = dateStr.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression)
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                                return dateFormatter.date(from: dateStr) ?? Date(timeIntervalSince1970: 0)
                            })
                            let bl = try decoder.decode(BeaconList.self, from: data)
                            UserDefaults.standard.orgBeaconListV2 = bl
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
    
    func triggerGivtLocation(id: String, organisationName: String) {
        delegate?.didDetectGivtLocation(orgName: organisationName, identifier: id)
    }
}

extension GivtService: BeaconServiceProtocol {
    func didUpdateBestBeacon(bestBeacon: BestBeacon) {
        self.bestBeacon = bestBeacon
    }
    
    func didDetectBeacon(scanMode: ScanMode, bestBeacon: BestBeacon) {
        if scanMode == .close {
            scanLock.lock()
            if (beaconService.isScanning) {
                stopScanning()
                let organisationName = GivtService.shared.determineOrganisationName(namespace: bestBeacon.namespace!)
                DispatchQueue.main.async {
                    self.give(antennaID: bestBeacon.beaconId!, organisationName: organisationName)
                }
            }
            scanLock.unlock()
        } else if scanMode == .far {
            triggerGivtLocation(id: bestBeacon.beaconId!, organisationName: self.getOrganisationName(organisationNameSpace: bestBeacon.namespace!)!)
        }
    }
    
    func didUpdateBluetoothState(isBluetoothOn: Bool) {
        delegate?.didUpdateBluetoothState(isBluetoothOn: isBluetoothOn)
    }
}

extension GivtService: LocationServiceProtocol {
    func didDiscoverLocationInRegion(location: GivtLocation) {
        triggerGivtLocation(id: location.beaconId, organisationName: location.organisationName)
    }
}

protocol GivtProcessedProtocol: class {
    func onGivtProcessed(transactions: [Transaction], organisationName: String?, canShare: Bool)
    func didUpdateBluetoothState(isBluetoothOn: Bool)
    func didDetectGivtLocation(orgName: String, identifier: String)
}

class BestBeacon {
    var beaconId: String?
    var rssi: NSNumber?
    var namespace: String?
    
    init(_ b: String? = nil,_ r: NSNumber? = nil,_ n: String? = nil) {
        beaconId = b
        rssi = r
        namespace = n
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
