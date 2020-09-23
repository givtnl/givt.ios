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
import Reachability
import AppCenterAnalytics
import Mixpanel

struct BeaconList: Codable {
    var OrgBeacons: [OrgBeacon]
    var LastChanged: Date
}

struct OrgBeacon: Codable {
    let EddyNameSpace: String
    let OrgName: String
    let Celebrations: Bool
    let Locations: [OrgBeaconLocation]
    var accountType: AccountType {
        get {
            let start = EddyNameSpace.index(EddyNameSpace.startIndex, offsetBy: 8)
            let end = EddyNameSpace.index(EddyNameSpace.startIndex, offsetBy: 12)
            
            let asciiCountry = EddyNameSpace[start..<end]
            if (asciiCountry == "4742" || asciiCountry == "4747" || asciiCountry == "4a45"){
                return AccountType.bacs
            }else {
                return AccountType.sepa
            }
        }
    }
    let collectGroupType: CollectGroupType?
    var tempCollectGroupType: CollectGroupType {
        get {
            var type: CollectGroupType
            switch MediumHelper.namespaceToOrganisationType(namespace: self.EddyNameSpace) {
            case .church:
                type = .church
            case .charity:
                type = .charity
            case .campaign:
                type = .campaign
            case .artist:
                type = .artist
            default:
                type = .unknown
            }
            return type
        }
    }
}

struct OrgBeaconLocation: Codable {
    let Name: String?
    let Latitude: Double
    let Longitude: Double
    let Radius: Int
    let BeaconId: String
    let dtBegin: Date
    let dtEnd: Date
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
    
    func getBluetoothState() -> BluetoothState {
        return beaconService.getBluetoothState()
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
        beaconService.delegate = self
        locationService.delegate = self
    }
    
    public func resume() {
        getBeaconsFromOrganisation { (status) in
            print(status)
        }
        
        getPublicMeta()
        
        if hasOfflineGifts() {
            BadgeService.shared.addBadge(badge: .offlineGifts)
        } else {
            BadgeService.shared.removeBadge(badge: .offlineGifts)
        }
        hasOfflineGifts() ? BadgeService.shared.addBadge(badge: .offlineGifts) : BadgeService.shared.removeBadge(badge: .offlineGifts)
        
        DispatchQueue.global(qos: .userInitiated).async {
            if AppServices.shared.isServerReachable {
                self.processCachedGivts();
            }
        }
    }
    
    func processCachedGivts() {
        cachedGivtsLock.lock()
        for (_, element) in UserDefaults.standard.offlineGivts.enumerated().reversed() {
            log.info(message: "Started processing chached Givts")
            giveInBackground(transactions: [element])
        }
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
        beaconService.startScanning(mode: scanMode)
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    func stopScanning() {
        beaconService.stopScanning()
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    func startLookingForGivtLocations() {
        startScanning(scanMode: .far)
        locationService.startLookingForLocation()
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    func stopLookingForGivtLocations() {
        stopScanning()
        locationService.stopLookingForLocation()
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    func give(antennaID: String, organisationName: String?) {
        LoginManager.shared.userClaim = .give //set to give so we show popup if user is still temp
        let date = Date().toISOString()
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
        MSAnalytics.trackEvent("GIVING_FINISHED", withProperties:["namespace": String((transactions[0].beaconId).prefix(20)),"online": String(reachability!.connection != .none)])
        Mixpanel.mainInstance().track(event: "GIVING_FINISHED", properties: ["namespace": String((transactions[0].beaconId).prefix(20)),"online": String(reachability!.connection != .none)])
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
    
    func giveManually(antennaId: String, afterGivt: ((Int, Bool, [Transaction], String) -> ())? = nil) {
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
            giveCelebrate(transactions: transactions, afterGivt: { resultData in
                if let result = resultData {
                    if let seconds = result["SecondsToCelebration"] as? Int {
                        afterGivt(seconds, false, transactions, self.getOrganisationName(organisationNameSpace: bestBeacon.namespace!)!)
                    } else if let queueSet = result["CelebrationQueueSet"] as? Bool {
                        afterGivt(-1, queueSet, transactions, self.getOrganisationName(organisationNameSpace: bestBeacon.namespace!)!)
                    } else {
                        afterGivt(-1, false, transactions, self.getOrganisationName(organisationNameSpace: bestBeacon.namespace!)!)
                    }
                } else {
                    MSAnalytics.trackEvent("GIVING_FINISHED", withProperties:["namespace": String((transactions[0].beaconId).prefix(20))])
                    Mixpanel.mainInstance().track(event: "GIVING_FINISHED", properties: ["namespace": String((transactions[0].beaconId).prefix(20))])
                    self.delegate?.onGivtProcessed(transactions: transactions,
                                                   organisationName: self.getOrganisationName(organisationNameSpace: bestBeacon.namespace!),
                                                   canShare: self.canShare(id: bestBeacon.beaconId!))
                }
            })
        } else {
            give(antennaID: bestBeacon.beaconId!, organisationName: self.getOrganisationName(organisationNameSpace: bestBeacon.namespace!))
        }
        
    }
    
    private func giveCelebrate(transactions: [Transaction], afterGivt: @escaping ([String: Any]?) -> ()) {
        cachedGivtsLock.lock()
        do {
            var object = ["Transactions": []]
            for transaction in transactions {
                object["Transactions"]?.append(transaction.convertToDictionary())
            }
            try client.post(url: "/api/Givts/Multiple", data: object) { (res) in
                if let res = res {
                    if res.basicStatus == .ok {
                        self.log.info(message: "Posted Givt to the server")
                        self.findAndRemoveCachedTransactions(transactions: transactions)
                        BadgeService.shared.removeBadge(badge: BadgeService.Badge.offlineGifts)
                        if let data = res.data {
                            do {
                                var resultData: [String: Any] = [:]
                                let parsedData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                                if let celebrationQueue = parsedData["CelebrationQueueSet"] as? Bool, let secondsToCelebration = parsedData["SecondsToCelebration"] as? Int {
                                    if celebrationQueue {
                                        resultData["CelebrationQueueSet"] = celebrationQueue
                                    }
                                    if secondsToCelebration > 0 {
                                        resultData["SecondsToCelebration"] = secondsToCelebration
                                    }
                                    afterGivt(resultData)
                                } else {
                                    afterGivt(nil)
                                }
                            } catch {
                                afterGivt(nil)
                            }
                        } else {
                            afterGivt(nil)
                        }
                    } else if res.status == .expectationFailed {
                        self.findAndRemoveCachedTransactions(transactions: transactions)
                        BadgeService.shared.removeBadge(badge: BadgeService.Badge.offlineGifts)
                        afterGivt(nil)
                    } else {
                        afterGivt(nil)
                    }
                } else {
                    //no response
                    afterGivt(nil)
                }
            }
        } catch {
            afterGivt(nil)
            self.log.error(message: "Unknown error : \(error)")
        }
        cachedGivtsLock.unlock()
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
        cachedGivtsLock.lock()
        do {
            var object = ["Transactions": []]
            for transaction in transactions {
                object["Transactions"]?.append(transaction.convertToDictionary())
            }
            if trycount < 3, object["Transactions"]?.count ?? 0 > 0 {
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
        cachedGivtsLock.unlock()
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
    
    func getPublicMeta(completion: @escaping (Bool?) -> Void = { _ in }) {
        if UserDefaults.standard.userExt?.guid == nil {
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
                        if let parsedYears = parsedData["YearsWithGivts"] as? [Int] {
                            UserDefaults.standard.yearsWithGivts = parsedYears
                        }
                        print("Has givts in \(year):", UserDefaults.standard.hasGivtsInPreviousYear)
                        if let parsedAccountType = parsedData["AccountType"] as? String {
                            if let accType = AccountType(rawValue: parsedAccountType.lowercased()){
                                UserDefaults.standard.accountType = accType
                            } else {
                                UserDefaults.standard.accountType = AccountType.undefined
                            }
                        }
                        if let parsedGiftAidSettings = parsedData["GiftAidSettings"] as? [String: AnyObject] {
                            if let shouldAskForPermission = parsedGiftAidSettings["ShouldAskForGiftAidPermission"] as? Bool {
                                completion(shouldAskForPermission)
                            } else {
                                completion(false)
                            }
                        } else{
                            completion(false)
                        }
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
   
    func sendGivtOverview(year: Int, callback: @escaping (Bool) -> Void) {
        var date = Date().getYear()-1
        if(year > 2015){
            date = year
        }
        client.get(url: "/api/v2/users/\(UserDefaults.standard.userExt!.guid)/givts/mail-report?year=\(date)", data: [:]) { (response) in
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
    
    func getSecondsLeftToCelebrate(collectGroupId: String, completion: @escaping (Int) -> Void) {
        client.get(url: "/api/v2/collectgroups/\(collectGroupId)/celebration", data: [:]) { (response) in
            if let response = response, let data = response.data {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                    if let secondsLeft = parsedData["SecondsRemaining"] as? Int {
                        completion(secondsLeft)
                        return
                    }
                } catch {
                    UserDefaults.standard.hasGivtsInPreviousYear = false //for the sake of it
                }
            }
            completion(-1)
        }
    }

    func getBeaconsFromOrganisation(tries: Int = 4, completionHandler: @escaping (Bool) -> Void) {
        
        if let userExt = UserDefaults.standard.userExt, !userExt.guid.isEmpty() {
            let data = ["Guid" : userExt.guid]
            client.get(url: "/api/v2/collectgroups/applist", data: data, timeout: 20, callback: { (response) in
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
                            if (tries > 0) {
                                self.getBeaconsFromOrganisation(tries: tries-1,  completionHandler: completionHandler)
                                self.log.warning(message: "Retrying the fetch beacon list.")
                                return
                            } else {
                                self.log.warning(message: "Stop trying to fetch beacon list.")
                            }
                            completionHandler(false)
                            print(err)
                        }
                    } else if response.statusCode == 204 {
                        completionHandler(false)
                        print("list up to date")
                    } else {
                        if (tries > 0) {
                            self.getBeaconsFromOrganisation(tries: tries-1,  completionHandler: completionHandler)
                            self.log.warning(message: "Retrying the fetch beacon list.")
                            return
                        } else {
                            self.log.warning(message: "Stop trying to fetch beacon list.")
                        }
                        completionHandler(false)
                        print("unknow statuscode")
                    }
                } else {
                    if (tries > 0) {
                        self.getBeaconsFromOrganisation(tries: tries-1,  completionHandler: completionHandler)
                        self.log.warning(message: "Retrying the fetch beacon list.")
                        return
                    } else {
                        self.log.warning(message: "Stop trying to fetch beacon list.")
                    }
                    print("no response from server?")
                    completionHandler(false)
                }
            })
        }
    }
    
    func triggerGivtLocation(id: String, organisationName: String) {
        delegate?.didDetectGivtLocation(orgName: organisationName, identifier: id)
    }
    
    func getMediumIdFromGivtLink(link: String) -> String? {
        let queryStrings = [ "https://www.givtapp.net/download?code=",
                             "https://www.givtapp.net/download/?code=",
                             "https://www.givt.app/download?code=",
                             "https://www.givt.app/download/?code=",
                             "https://api.givtapp.net/givt?code=",
                             "https://api.givtapp.net/givt/?code=",
                             "https://givt-debug-api.azurewebsites.net/givt?code=",
                             "https://givt-debug-api.azurewebsites.net/givt/?code="]
        
        for queryString in queryStrings {
            let idxqs = link.index(of: queryString)
            if idxqs != nil, let decoded = String(link[queryString.endIndex...]).base64Decoded() {
                return decoded
            }
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
    
    func didUpdateBluetoothState(bluetoothState: BluetoothState) {
        delegate?.didUpdateBluetoothState(bluetoothState: bluetoothState)
    }
}

extension GivtManager: LocationServiceProtocol {
    func didDiscoverLocationInRegion(location: GivtLocation) {
        triggerGivtLocation(id: location.beaconId, organisationName: location.organisationName)
    }
}

protocol GivtProcessedProtocol: class {
    func onGivtProcessed(transactions: [Transaction], organisationName: String?, canShare: Bool)
    func didUpdateBluetoothState(bluetoothState: BluetoothState)
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

class Transaction: NSObject, NSCoding, Codable {
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
