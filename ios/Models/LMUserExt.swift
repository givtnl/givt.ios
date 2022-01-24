//
//  LMUserExt.swift
//  ios
//
//  Created by Lennie Stockman on 03/07/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import Foundation

struct LMUserExt: Codable {
    var GUID: String
    var PhoneNumber: String
    var FirstName: String?
    var LastName: String?
    var Email: String
    var Address: String?
    var PostalCode: String?
    var Country: String
    var IBAN: String?
    var SortCode: String?
    var AccountNumber: String?
    var City: String?
    var IsTempUser: Bool
    var AmountLimit: Int
    var PayProvMandateStatus: String?
    var AccountType: String
    var GiftAidEnabled: Bool
}
