//
//  USRegistrationViewControllerCreditCardExpiryDateExtension.swift
//  ios
//
//  Created by Mike Pattyn on 18/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//
import Foundation
import UIKit
import MonthYearPicker

extension USRegistrationViewController {
    func setupExpiryDate() {
        creditCardExpiryDateTextField.tag = USRegistrationFieldType.creditCardExpiryDate.rawValue
        creditCardExpiryDateTextField.delegate = self
        creditCardExpiryDateTextField.textContentType = UITextContentType.expiryDate
        creditCardExpiryDateTextField.keyboardType = .numberPad
        createToolbar(creditCardExpiryDateTextField)
    }
}
