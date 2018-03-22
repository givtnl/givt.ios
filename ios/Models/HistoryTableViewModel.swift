//
//  HistoryTableViewModel.swift
//  ios
//
//  Created by Lennie Stockman on 22/03/18.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation
class HistoryTableViewModel {
    var orgName: String
    var timestamp: Date
    var status : NSNumber
    var collections: [Collecte]
    
    init(orgName: String, timestamp: Date, status: NSNumber, collections: [Collecte]) {
        self.orgName = orgName
        self.timestamp = timestamp
        self.status = status
        self.collections = collections
    }
}

class Collecte {
    var collectId: Decimal
    var amount: Double
    var amountString: String
    
    init(collectId: Decimal, amount: Double, amountString: String) {
        self.collectId = collectId
        self.amount = amount
        self.amountString = amountString
    }
}
