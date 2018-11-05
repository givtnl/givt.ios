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
import Reachability

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
    var accountType: AccountType {
        get {
            let start = EddyNameSpace.index(EddyNameSpace.startIndex, offsetBy: 8)
            let end = EddyNameSpace.index(EddyNameSpace.startIndex, offsetBy: 12)
            
            let asciiCountry = EddyNameSpace[start..<end]
            if (asciiCountry == "4742"){
                return AccountType.bacs
            }else {
                return AccountType.sepa
            }
        }
    }
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

final class GivtManager: NSObject {
    private let beaconService = BeaconService()
    static let shared = GivtManager()
    private var log = LogService.shared
    private var locationService = LocationService.instance
    let reachability = Reachability()
    
    static let FEAA = CBUUID.init(string: "FEAA")
    
    private var client = APIClient.shared
    private var amount: Decimal!
    private var amounts = [Decimal]()
    private var scanLock = NSRecursiveLock()
    
    var externalIntegration: ExternalAppIntegration?
    
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
    
    func hasOfflineGifts() -> Bool {
        return UserDefaults.standard.offlineGivts.count > 0
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
    private var cachedGivtsLock = NSRecursiveLock()
    
    private override init() {
        super.init()
        resume()
        
        NotificationCenter.default.addObserver(self, selector: #selector(connectionStatusDidChange(notification:)), name: .GivtConnectionStateDidChange, object: nil)
    }
    
    public func resume() {
        getBeaconsFromOrganisation { (status) in
            print(status)
        }
        
        getPublicMeta()
        
        hasOfflineGifts() ? BadgeService.shared.addBadge(badge: .offlineGifts) : BadgeService.shared.removeBadge(badge: .offlineGifts)
    }
    
    func processCachedGivts() {
        cachedGivtsLock.lock()
        for (index, element) in UserDefaults.standard.offlineGivts.enumerated().reversed() {
            log.info(message: "Started processing chached Givts")
            giveInBackground(transactions: [element])
            UserDefaults.standard.offlineGivts.remove(at: index)
        }
        BadgeService.shared.removeBadge(badge: .offlineGifts)
        cachedGivtsLock.unlock()
    }
    
    @objc func connectionStatusDidChange(notification: Notification) {
        if let canSend = notification.object as? Bool {
            print("Server is reachable ?  \(canSend)")
            if canSend {
                processCachedGivts()
            }
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
        self.cacheGivt(transactions: transactions)
        giveInBackground(transactions: transactions)
        self.delegate?.onGivtProcessed(transactions: transactions, organisationName: organisationName, canShare: canShare(id: antennaID))
    }
    
    func giveQR(scanResult: String, completionHandler: @escaping (Bool) -> Void) {
        if let mediumid = getMediumIdFromGivtLink(link: scanResult) {
            let bestBeacon = BestBeacon()
            /* mimic bestbeacon */
            bestBeacon.beaconId = mediumid
            if let idx = mediumid.index(of: ".") {
                bestBeacon.namespace = String(mediumid[..<idx])
            } else {
                bestBeacon.namespace = mediumid
            }
            self.bestBeacon = bestBeacon
            //bepaal naam
            give(antennaID: mediumid, organisationName: self.getOrganisationName(organisationNameSpace: bestBeacon.namespace!))
            completionHandler(true)
        } else {
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
        self.bestBeacon = bestBeacon
        
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
            
            self.cacheGivt(transactions: transactions)
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
                        self.findAndRemoveCachedTransactions(transactions: transactions)
                        BadgeService.shared.removeBadge(badge: BadgeService.Badge.offlineGifts)
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
                    } else if res.status == .expectationFailed {
                        self.findAndRemoveCachedTransactions(transactions: transactions)
                        BadgeService.shared.removeBadge(badge: BadgeService.Badge.offlineGifts)
                        afterGivt(-1)
                    } else {
                        afterGivt(-1)
                    }
                } else {
                    //no response
                    afterGivt(-1)
                }
            }
        } catch {
            afterGivt(-1)
            self.log.error(message: "Unknown error : \(error)")
        }
    }
    
    private func cacheGivt(transactions: [Transaction]){
        self.log.info(message: "Caching givt(s)")
        for tr in transactions {
            UserDefaults.standard.offlineGivts.append(tr)
        }
        BadgeService.shared.addBadge(badge: .offlineGifts)
    }
    
    private func findAndRemoveCachedTransactions(transactions: [Transaction]) {
        for tr in transactions {
            if let idx = UserDefaults.standard.offlineGivts.index(where: { (trans) -> Bool in
                return trans.amount == tr.amount
                    && trans.beaconId == tr.beaconId
                    && trans.collectId == tr.collectId
                    && trans.timeStamp == tr.timeStamp
                    && trans.userId == tr.userId
            }) {
                UserDefaults.standard.offlineGivts.remove(at: idx)
            }
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
                            self.findAndRemoveCachedTransactions(transactions: transactions)
                            BadgeService.shared.removeBadge(badge: BadgeService.Badge.offlineGifts)
                        } else if res.status == .expectationFailed {
                            self.log.warning(message: "Givt was not sent to server. Gave between 30s?")
                            self.findAndRemoveCachedTransactions(transactions: transactions)
                            BadgeService.shared.removeBadge(badge: BadgeService.Badge.offlineGifts)
                        } else {
                            self.tryGive(transactions: transactions, trycount: trycount+1)
                        }
                    }
                }
            } else {
                self.log.error(message: "Didn't get response from server! Givt has been cached")
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
        if UserDefaults.standard.userExt == nil || UserDefaults.standard.userExt!.guid == nil {
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
                        if let parsedAccountType = parsedData["AccountType"] as? String {
                            if let accType = AccountType(rawValue: parsedAccountType.lowercased()){
                                UserDefaults.standard.accountType = accType
                            } else {
                                UserDefaults.standard.accountType = AccountType.undefined
                            }
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
            let data = ["Guid" : userExt.guid]
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
    
    func getMediumIdFromGivtLink(link: String) -> String?{
        let queryString = "https://www.givtapp.net/download?code="
        let queryString2 = "https://www.givt.app/download?code="
        let idxqs = link.index(of: queryString)
        let idxqs2 = link.index(of: queryString2)
        if idxqs != nil || idxqs2 != nil {
            var encoded: String;
            if idxqs != nil {
                encoded = String(link[queryString.endIndex...])
            } else if idxqs2 != nil {
                encoded = String(link[queryString2.endIndex...])
            } else { return nil }
            
            if let decoded = encoded.base64Decoded() {
                return decoded
            } else {
                //todo: log messed up base 64
            }
        } else {
            //todo log result: not our qr code
        }
        return nil;
    }
    
    func hasGivtLocations() -> Bool {
        return locationService.hasActiveGivtLocations()
    }
}

extension GivtManager: BeaconServiceProtocol {
    func didUpdateBestBeacon(bestBeacon: BestBeacon) {
        self.bestBeacon = bestBeacon
    }
    
    func didDetectBeacon(scanMode: ScanMode, bestBeacon: BestBeacon) {
        if scanMode == .close {
            scanLock.lock()
            if (beaconService.isScanning) {
                stopScanning()
                let organisationName = GivtManager.shared.determineOrganisationName(namespace: bestBeacon.namespace!)
                DispatchQueue.main.async {
                    self.give(antennaID: bestBeacon.beaconId!, organisationName: organisationName)
                }
            }
            scanLock.unlock()
        } else if scanMode == .far {
            if let orgName = self.getOrganisationName(organisationNameSpace: bestBeacon.namespace!) {
                triggerGivtLocation(id: bestBeacon.beaconId!, organisationName: orgName)
            } else {
                self.log.warning(message: "Found a location beacon that is not a known namespace in the db. Beacon found: \(bestBeacon.beaconId!)")
            }
        }
    }
    
    func didUpdateBluetoothState(isBluetoothOn: Bool) {
        delegate?.didUpdateBluetoothState(isBluetoothOn: isBluetoothOn)
    }
}

extension GivtManager: LocationServiceProtocol {
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
