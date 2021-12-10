//
//  USRegistrationViewControllerCreditCardNumberExtension.swift
//  ios
//
//  Created by Mike Pattyn on 18/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//
import Foundation
import UIKit

extension USRegistrationViewController {
    func setupCreditCardNumber() {
        creditCardNumberView.layer.borderWidth = 1
        creditCardNumberView.layer.cornerRadius = 4
        creditCardNumberView.layer.borderColor = creditCardNumberTextField.layer.borderColor
        creditCardNumberTextField.keyboardType = .numberPad
        creditCardNumberTextField.layer.borderWidth = 0
        creditCardNumberTextField.layer.borderColor = UIColor.clear.cgColor
        creditCardNumberTextField.borderStyle = .none
        creditCardNumberTextField.tag = USRegistrationFieldType.creditCardNumber.rawValue
        creditCardNumberTextField.delegate = self
        // For autofill
        creditCardNumberTextField.textContentType = UITextContentType.creditCardNumber
        
        creditCardNumberTextField.placeholder = "US.Registration.CreditCard.Details.Number.Placeholder".localized
        
        createToolbar(creditCardNumberTextField)
    }
}
