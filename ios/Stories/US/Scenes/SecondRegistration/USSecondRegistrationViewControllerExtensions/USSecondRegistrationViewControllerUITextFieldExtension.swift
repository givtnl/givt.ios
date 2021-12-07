//
//  USSecondRegistrationViewControllerUITextFieldExtension.swift
//  ios
//
//  Created by Mike Pattyn on 06/12/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

enum USSecondRegistrationFieldType: Int {
    case firstName
    case lastName
}

extension USSecondRegistrationViewController: UITextFieldDelegate {
    // MARK: During editing
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var currentValueInField = textField.text,
              let fieldTypeTag = USSecondRegistrationFieldType(rawValue: textField.tag) else {
            return true
        }
        if (string == String.empty) {
            currentValueInField.removeLast()
            return true
        }
        if (fieldTypeTag == .firstName) {
            if (String(currentValueInField+string).count >= 2) {
                return false
            }
        }
        if (fieldTypeTag == .lastName) {
            if (String(currentValueInField+string).count >= 2) {
                return false
            }
        }
        viewModel.handleTextChanged(fieldTypeTag: fieldTypeTag, input: currentValueInField+string)
        return true
    }
    
    // MARK: When editing ends
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text! = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let fieldTypeTag = USSecondRegistrationFieldType(rawValue: textField.tag) else {
            return
        }
        viewModel.handleValidationRequest(fieldTypeTag: fieldTypeTag)
        viewModel.validateAllFields?()
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
