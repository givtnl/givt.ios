//
//  USRegistrationViewControllerPhoneNumberExtension.swift
//  ios
//
//  Created by Mike Pattyn on 18/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//
import Foundation
import UIKit

extension USRegistrationViewController {
    func setupPhoneNumberField() {
        phoneNumberTextField.text = "+1"
        phoneNumberTextField.delegate = self
        phoneNumberTextField.tag = USRegistrationFieldType.phoneNumber.rawValue
        phoneNumberTextField.keyboardType = .phonePad
        
        phoneNumberTextField.textContentType = UITextContentType.telephoneNumber
        
        createToolbar(phoneNumberTextField)
    }
}
