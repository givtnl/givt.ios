//
//  CreditCardControlViewModel.swift
//  ios
//
//  Created by Mike Pattyn on 09/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
import GivtCodeShare

class CreditCardControlViewModel: NSObject {
    var creditCardValidator: CreditCardValidator = CreditCardValidator()
    
    var validateCardNumber: NillableClosure!
    var validateExpiryDate: NillableClosure!
    var validateSecurityCode: NillableClosure!
    
    var setCardNumberTextField:  NillableClosure!
    var setCreditCardCompanyLogo: NillableClosure!
    var setExpiryTextField: NillableClosure!
    var setCVVTextField: NillableClosure!
    
    var updateView: NillableClosure!
    
    func setValues(cardNumber: String, expiryDate: String, securityCode: String) {
        creditCardValidator.creditCard.number = cardNumber
        creditCardValidator.creditCard.expiryDate.setValue(inputString: expiryDate)
        creditCardValidator.creditCard.securityCode = securityCode
        updateView?()
    }
}

enum CreditCardInputFieldType: Int {
    case number
    case expiration
    case cvv
}
