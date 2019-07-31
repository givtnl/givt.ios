//
//  HistoryTransaction.swift
//  ios
//
//  Created by Lennie Stockman on 22/03/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
class HistoryTransaction: NSObject {
    public var id: Int
    public var orgName : String
    public var amount : Double
    public var collectId : Decimal
    public var timestamp : Date
    public var status : NSNumber
    public var giftAid: Bool
    
    /**
     Returns an array of models based on given dictionary.
     
     Sample usage:
     let json4Swift_Base_list = Json4Swift_Base.modelsFromDictionaryArray(someDictionaryArrayFromJSON)
     
     - parameter array:  NSArray from JSON dictionary.
     
     - returns: Array of Json4Swift_Base Instances.
     */
    public class func modelsFromDictionaryArray(array:NSArray) -> [HistoryTransaction]
    {
        var models:[HistoryTransaction] = []
        for item in array
        {
            models.append(HistoryTransaction(dictionary: item as! Dictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: Dictionary<String, Any>) {
        id = (dictionary["Id"] as? Int)!
        orgName = (dictionary["OrgName"] as? String)!
        amount = Double((dictionary["Amount"] as? Double)!)
        collectId = Decimal(string: dictionary["CollectId"] as! String)!
        var dateString = (dictionary["Timestamp"] as? String)!
        if dateString.count > 19 {
            dateString = dateString.substring(0..<19)
        }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.locale = Locale(identifier: "en_US_POSIX")
        timestamp = df.date(from: dateString)!
        status = (dictionary["Status"] as? NSNumber)!
        giftAid = ((dictionary["GiftAid"] as? String) != nil)
    }
    
    public func dictionaryRepresentation() -> Dictionary<String , Any> {
        
        var dictionary = Dictionary<String, Any>()
        dictionary.updateValue(self.orgName, forKey: "OrgName")
        dictionary.updateValue(self.amount, forKey: "Amount")
        dictionary.updateValue(self.collectId, forKey: "CollectId")
        dictionary.updateValue(self.timestamp, forKey: "Timestamp")
        dictionary.updateValue(self.status, forKey: "Status")
        dictionary.updateValue(self.id, forKey: "Id")
        dictionary.updateValue(self.giftAid, forKey: "GiftAid")
        
        return dictionary
    }
    
}
