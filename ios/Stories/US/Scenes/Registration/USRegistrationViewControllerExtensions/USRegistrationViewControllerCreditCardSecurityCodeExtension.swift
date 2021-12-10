//
//  USRegistrationViewControllerCreditCardSecurityCodeExtension.swift
//  ios
//
//  Created by Mike Pattyn on 18/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//
import Foundation
import UIKit

extension USRegistrationViewController {
    func setupCVV() {
        creditCardCVVTextField.keyboardType = .numberPad
        creditCardCVVTextField.tag = USRegistrationFieldType.creditCardSecurityCode.rawValue
        creditCardCVVTextField.delegate = self
        creditCardCVVTextField.textContentType = UITextContentType.securityCode
        creditCardCVVTextField.placeholder = "US.Registration.CreditCard.Details.SecurityCode.Placeholder".localized
        createToolbar(creditCardCVVTextField)
    }
}
