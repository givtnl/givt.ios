//
//  USRegistrationViewControllerCreditCardExpiryDateExtension.swift
//  ios
//
//  Created by Mike Pattyn on 18/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//
import Foundation
import UIKit

extension USRegistrationViewController {
    func setupExpiryDate() {
        creditCardExpiryDateTextField.tag = USRegistrationFieldType.creditCardExpiryDate.rawValue
        creditCardExpiryDateTextField.delegate = self
        creditCardExpiryDateTextField.textContentType = UITextContentType.expiryDate
        creditCardExpiryDateTextField.keyboardType = .numberPad
        creditCardExpiryDateTextField.placeholder = "US.Registration.CreditCard.Details.ExpiryDate.Placeholder".localized
        createToolbar(creditCardExpiryDateTextField)
    }
}
