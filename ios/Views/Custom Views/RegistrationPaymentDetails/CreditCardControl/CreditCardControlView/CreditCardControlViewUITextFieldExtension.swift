//
//  CreditCardControlViewUITextFieldExtension.swift
//  ios
//
//  Created by Mike Pattyn on 13/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
import GivtCodeShare

extension CreditCardControlView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let controlTag = CreditCardInputFieldType(rawValue: textField.tag) {
            switch(controlTag) {
            case CreditCardInputFieldType.expiration:
                viewModel.validateExpiryDate?()
                break
            case CreditCardInputFieldType.cvv:
                viewModel.validateSecurityCode?()
                break
            case CreditCardInputFieldType.number:
                viewModel.validateCardNumber?()
                break
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let controlTag = CreditCardInputFieldType(rawValue: textField.tag) {
            switch(controlTag) {
            case CreditCardInputFieldType.number:
                if var currentValueInField = textField.text {
                    if string.isEmpty() {
                        currentValueInField.removeLast()
                    }
                    viewModel.creditCardValidator.creditCard.number = "\(currentValueInField)\(string)"
                    viewModel.setCreditCardCompanyLogo?()
                    viewModel.setCardNumberTextField?()
                }
                break
            case CreditCardInputFieldType.expiration:
                if var currentValueInField = textField.text {
                    if string == String.empty {
                        currentValueInField.removeLast()
                    }
                    currentValueInField = currentValueInField.replacingOccurrences(of: "/", with: "")
                    viewModel.creditCardValidator.creditCard.expiryDate.setValue(inputString: "\(currentValueInField)\(string)")
                    if currentValueInField.count > 2 {
                        viewModel.setExpiryTextField?()
                    }
                }
            default:
                break
            }
        }
        return true
    }
}
