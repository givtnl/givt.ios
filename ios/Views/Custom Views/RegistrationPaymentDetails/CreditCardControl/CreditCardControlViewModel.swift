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
    
    var validateCardNumber:  (()->())?
    var validateExpiryDate:  (()->())?
    var validateSecurityCode: (()->())?
    
    var setCardNumberTextField:  (()->())?
    var setCreditCardCompanyLogo: (()->())?
    var setExpiryTextField: (() -> ())?
}

enum CreditCardInputFieldType: Int {
    case number
    case expiration
    case cvv
}
