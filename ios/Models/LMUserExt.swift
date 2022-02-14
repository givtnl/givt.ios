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
    var CreditCardNumber: String?
    
    func getFullAddress() throws -> String {
        switch Country {
            case "US":
                return Locale.current.localizedString(forRegionCode: Country)!
            default:
                return Address! + "\n" + PostalCode! + " " + City! + ", " + Locale.current.localizedString(forRegionCode: Country)!
        }
    }
    
    func getFullName() throws -> String {
        return "\(FirstName!) \(LastName!)"
    }
    
    func getPrettyIban() throws -> String {
        return IBAN!.chunked(by: 4)
    }
    
    func getPrettySortCodeAndAccountNumber() throws -> String {
        return "BacsSortcodeAccountnumber".localized
            .replacingOccurrences(of: "{0}", with: SortCode!)
            .replacingOccurrences(of: "{1}", with: AccountNumber!)
    }
    
    func getPaymentType() throws -> PaymentType {
        if IBAN != nil {
            return .SEPADirectDebit
        } else if SortCode != nil {
            return .BACSDirectDebit
        } else if CreditCardNumber != nil {
            return .CreditCard
        } else {
            return .Undefined
        }  
    }
}
