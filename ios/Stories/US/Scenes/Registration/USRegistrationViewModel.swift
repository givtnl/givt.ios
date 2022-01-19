//
//  USRegistrationViewModel.swift
//  ios
//
//  Created by Mike Pattyn on 14/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import GivtCodeShare
import UIKit

typealias NillableClosure = (()->())?

class USRegistrationViewModel {
    var registrationValidator: RegistrationValidator = RegistrationValidator()
    var creditCardValidator: CreditCardValidator = CreditCardValidator()

    var phoneNumber: String!
    var emailAddress: String!
    var password: String!
    
    var validatePhoneNumber: NillableClosure!
    var validatePassword: NillableClosure!
    var validateAllFields: NillableClosure!
    
    var setPasswordTextField: NillableClosure!
    var setPhoneNumberTextField: NillableClosure!
    
    var updateView: NillableClosure!
        
    func setValues(phoneNumber: String, password: String) {
        registrationValidator.phoneNumber = phoneNumber
        registrationValidator.password = password
        updateView?()
    }
    
    var allFieldsValid: Bool {
        get {
            return registrationValidator.isValidPassword && registrationValidator.isValidPhoneNumber
        }
    }
    
    func handleTextChanged(fieldTypeTag: USRegistrationFieldType, input: String) {
        switch(fieldTypeTag) {
        case .phoneNumber:
            var input = input
            if input == "" {
                input = "+1"
            }
            registrationValidator.phoneNumber = input
            setPhoneNumberTextField?()
            break
        case .password:
            registrationValidator.password = input
            setPasswordTextField?()
            break
        default:
            break
        }
    }
    
    func handleValidationRequest(fieldTypeTag: USRegistrationFieldType) {
        switch(fieldTypeTag) {
        case .phoneNumber:
            validatePhoneNumber?()
            break
        case .password:
            validatePassword?()
            break
        default:
            break
        }
    }
}
