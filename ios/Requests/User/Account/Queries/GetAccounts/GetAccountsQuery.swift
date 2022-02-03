//
//  GetCreditCardQuery.swift
//  ios
//
//  Created by Mike Pattyn on 25/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import GivtCodeShare

internal class GetAccountsQuery : RequestProtocol {
    typealias TResponse = ResponseModel<[AccountDetailModel]?>
}

class CreditCardDetailsModel: Codable {
    var cardNumber: String?
    var cardType: String?

    init(cardNumber: String?, cardType: String?) {
        self.cardNumber = cardNumber
        self.cardType = cardType
    }
}
