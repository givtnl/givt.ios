//
//  USRegistrationViewModel.swift
//  ios
//
//  Created by Mike Pattyn on 14/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import GivtCodeShare
typealias NillableClosure = (()->())?

class USRegistrationViewModel {
    var registrationValidator: RegistrationValidator = RegistrationValidator()
    var creditCardViewModel: CreditCardControlViewModel!
    
    var phoneNumber: String!
    var emailAddress: String!
    var password: String!
    
    var validatePhoneNumber: NillableClosure!
    var validateEmailAddress: NillableClosure!
    var validatePassword: NillableClosure!
    var validateAllFields: NillableClosure!
    
    var setPasswordTextField: NillableClosure!
    var setPhoneNumberTextField: NillableClosure!
    var setEmailAddressTextField: NillableClosure!
    
    var updateView: NillableClosure!
    
    func setValues(phoneNumber: String, emailAddress: String, password: String) {
        registrationValidator.phoneNumber = phoneNumber
        registrationValidator.emailAddress = emailAddress
        registrationValidator.password = password
        updateView?()
    }
    
    var allFieldsValid: Bool {
        get {
            return creditCardViewModel.creditCardValidator.isValidCreditCard && registrationValidator.isValidRegistrationData
        }
    }
    
    func handleTextChanged(fieldTypeTag: USRegistrationFieldType, input: String) {
        switch(fieldTypeTag) {
            case .phoneNumber:
                phoneNumber = input
                break
            case .emailAddress:
                emailAddress = input
                break
            case .password:
                password = input
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
            case .emailAddress:
                validatePassword?()
                break
        }
    }
}
