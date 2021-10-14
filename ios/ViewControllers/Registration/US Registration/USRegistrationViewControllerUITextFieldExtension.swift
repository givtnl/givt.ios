//
//  USRegistrationViewControllerUITextFieldDelegate.swift
//  ios
//
//  Created by Mike Pattyn on 14/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

enum USRegistrationFieldType: Int {
    case phoneNumber
    case emailAddress
    case password
}

extension USRegistrationViewController: UITextFieldDelegate {
    // MARK: During editing
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentValueInField = textField.text,
              let fieldTypeTag = USRegistrationFieldType(rawValue: textField.tag) else {
            return true
        }
        viewModel.handleTextChanged(fieldTypeTag: fieldTypeTag, input: currentValueInField+string)
        return true
    }
    
    // MARK: When editing ends
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text! = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let fieldTypeTag = USRegistrationFieldType(rawValue: textField.tag) else {
            return
        }
        viewModel.handleValidationRequest(fieldTypeTag: fieldTypeTag)
    }
    
    // MARK: When return button is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType != .done {
            textField.resignFirstResponder()
            return false
        }
        
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false //prevents adding line break
    }
}
