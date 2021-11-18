//
//  USRegistrationViewControllerPhoneNumberExtension.swift
//  ios
//
//  Created by Mike Pattyn on 18/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//
import Foundation

extension USRegistrationViewController {
    func setupPhoneNumberField() {
        phoneNumberTextField.placeholder = "+1"
        phoneNumberTextField.delegate = self
        phoneNumberTextField.tag = USRegistrationFieldType.phoneNumber.rawValue
        phoneNumberTextField.keyboardType = .phonePad
        createToolbar(phoneNumberTextField)
    }
}
