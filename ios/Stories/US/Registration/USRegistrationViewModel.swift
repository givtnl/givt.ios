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
    var creditCardValidator: CreditCardValidator = CreditCardValidator()

    var phoneNumber: String!
    var emailAddress: String!
    var password: String!
    
    var validateCardNumber: NillableClosure!
    var validateExpiryDate: NillableClosure!
    var validateSecurityCode: NillableClosure!
    var validatePhoneNumber: NillableClosure!
    var validatePassword: NillableClosure!
    var validateAllFields: NillableClosure!
    
    var setCardNumberTextField:  NillableClosure!
    var setCreditCardCompanyLogo: NillableClosure!
    var setExpiryTextField: NillableClosure!
    var setCVVTextField: NillableClosure!
    var setPasswordTextField: NillableClosure!
    var setPhoneNumberTextField: NillableClosure!
    
    var updateView: NillableClosure!
        
    func setValues(phoneNumber: String, password: String, cardNumber: String, expiryDate: String, securityCode: String) {
        registrationValidator.phoneNumber = phoneNumber
        registrationValidator.password = password
        creditCardValidator.creditCard.number = cardNumber
        creditCardValidator.creditCard.expiryDate.rawValue = expiryDate
        creditCardValidator.creditCard.securityCode = securityCode
        updateView?()
    }
    
    var allFieldsValid: Bool {
        get {
            return creditCardValidator.isValidCreditCard && registrationValidator.isValidPassword && registrationValidator.isValidPhoneNumber
        }
    }
    
    func handleTextChanged(fieldTypeTag: USRegistrationFieldType, input: String) {
        switch(fieldTypeTag) {
        case .phoneNumber:
            registrationValidator.phoneNumber = input
            break
        case .password:
            registrationValidator.password = input
            break
        case .creditCardNumber:
            creditCardValidator.creditCard.number = input
            setCreditCardCompanyLogo?()
            setCardNumberTextField?()
            break
        case .creditCardExpiryDate:
            if input.count == 5 {
                return
            }
            creditCardValidator.creditCard.expiryDate.rawValue = input
            if input.count >= 3 {
                setExpiryTextField?()
            }
            break
        case .creditCardSecurityCode:
            creditCardValidator.creditCard.securityCode = input
            setCVVTextField?()
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
        case .creditCardNumber:
            validateCardNumber?()
            break
        case .creditCardExpiryDate:
            validateExpiryDate?()
            break
        case .creditCardSecurityCode:
            validateSecurityCode?()
            break
        }
    }
}
