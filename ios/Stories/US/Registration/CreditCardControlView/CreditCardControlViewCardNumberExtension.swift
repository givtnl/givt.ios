//
//  CreditCardControlViewCardNumberExtension.swift
//  ios
//
//  Created by Mike Pattyn on 13/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
import GivtCodeShare

extension CreditCardControlView {
    func setupCreditCardNumber() {
        creditCardNumberView.layer.borderWidth = 1
        creditCardNumberView.layer.cornerRadius = 4
        creditCardNumberView.layer.borderColor = creditCardNumberTextField.layer.borderColor
        creditCardNumberTextField.keyboardType = .numberPad
        creditCardNumberTextField.layer.borderWidth = 0
        creditCardNumberTextField.layer.borderColor = UIColor.clear.cgColor
        creditCardNumberTextField.borderStyle = .none
        creditCardNumberTextField.tag = CreditCardInputFieldType.number.rawValue
        creditCardNumberTextField.delegate = self
        createToolbar(creditCardNumberTextField)
    }
}

public func getCreditCardCompanyEnumValue(value: String) -> CreditCardCompany {
    switch(value.lowercased()) {
    case "amex", "americanexpress":
        return .americanexpress
    case "discover":
        return .discover
    case "mastercard":
        return .mastercard
    case "visa":
        return .visa
    default:
        return .undefined
    }
}
public func getCreditCardCompanyLogo(_ creditCardCompany: CreditCardCompany) -> UIImage {
    switch(creditCardCompany) {
    case .americanexpress:
        return UIImage(imageLiteralResourceName: "AmericanExpress")
    case .discover:
        return UIImage(imageLiteralResourceName: "Discover")
    case .mastercard:
        return UIImage(imageLiteralResourceName: "MasterCard")
    case .visa:
        return UIImage(imageLiteralResourceName: "Visa")
    default:
        return UIImage(imageLiteralResourceName: "card")
    }
}
