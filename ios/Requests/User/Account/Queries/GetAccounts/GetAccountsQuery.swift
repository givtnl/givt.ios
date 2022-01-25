//
//  GetCreditCardQuery.swift
//  ios
//
//  Created by Mike Pattyn on 25/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

internal class GetAccountsQuery : RequestProtocol {
    typealias TResponse = ResponseModel<GetAccountsResponseModel?>
}

internal class GetAccountsResponseModel: Codable {
    var accounts: [AccountsDetailModel]?
    internal init(accounts: [AccountsDetailModel]?) {
        self.accounts = accounts
    }
}
extension GetAccountsResponseModel {
    static func fromDictionaryStringAny(dictionary: [[String: Any]]) -> GetAccountsResponseModel {
        return GetAccountsResponseModel(accounts: fromDictionaryToAccountsArray(dictionary: dictionary))
    }
    private static func fromDictionaryToAccountsArray(dictionary: [[String: Any]]) -> [AccountsDetailModel]? {
        var accountsArray: [AccountsDetailModel]?
        for dict in dictionary {
            if (accountsArray == nil) {
                accountsArray = [AccountsDetailModel]()
            }
            let accountsDetail = AccountsDetailModel(
                id: dict["Id"] as! Int,
                iban: dict["Iban"] as? String,
                accountNumber: dict["AccountNumber"] as? String,
                sortCode: dict["SortCode"] as? String,
                accountName: dict["AccountName"] as? String,
                primary: dict["Primary"] as! Bool,
                active: dict["Active"] as! Bool,
                verified: dict["Verified"] as! Bool,
                creditCardDetails: CreditCardDetailsModel(
                    cardNumber: (dict["CreditCardDetails"] as! [String: String?])["CardNumber"] as? String,
                    cardType: (dict["CreditCardDetails"] as! [String: String?])["CardType"] as? String
                )
            )
            accountsArray?.append(accountsDetail)
        }
        
        return accountsArray
    }
}
internal class AccountsDetailModel: Codable {
    var id: Int
    var iban, accountNumber, sortCode, accountName: String?
    var primary, active, verified: Bool
    var creditCardDetails: CreditCardDetailsModel?

    init(id: Int, iban: String?, accountNumber: String?, sortCode: String?, accountName: String?, primary: Bool, active: Bool, verified: Bool, creditCardDetails: CreditCardDetailsModel?) {
        self.id = id
        self.iban = iban
        self.accountNumber = accountNumber
        self.sortCode = sortCode
        self.accountName = accountName
        self.primary = primary
        self.active = active
        self.verified = verified
        self.creditCardDetails = creditCardDetails
    }
}

class CreditCardDetailsModel: Codable {
    var cardNumber: String?
    var cardType: String?

    init(cardNumber: String?, cardType: String?) {
        self.cardNumber = cardNumber
        self.cardType = cardType
    }
}
