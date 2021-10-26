//
//  RegisterCreditCardCommand.swift
//  ios
//
//  Created by Mike Pattyn on 22/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
internal class RegisterCreditCardCommand : RequestProtocol, Codable {
    typealias TResponse = ResponseModel<Bool>
    
    var creditCardDetails: CreditCardDetails
    internal init(creditCardDetails: CreditCardDetails) {
        self.creditCardDetails = creditCardDetails
    }
}

internal class CreditCardDetails: Codable {
    var cardNumber: String
    var expirationMonth: Int
    var expirationYear: Int
    
    internal init(cardNumber: String,
                  expirationMonth: Int,
                  expirationYear: Int) {
        self.cardNumber = cardNumber
        self.expirationMonth = expirationMonth
        self.expirationYear = expirationYear
    }
}
