//
//  USSecondRegistrationViewModel.swift
//  ios
//
//  Created by Mike Pattyn on 06/12/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import GivtCodeShare

class USSecondRegistrationViewModel {
    var registrationValidator: RegistrationValidator = RegistrationValidator()

    var firstName: String!
    var lastName: String!
    var postalCode: String!
    
    var validateFirstName: NillableClosure!
    var validateLastName: NillableClosure!
    var validatePostalCode: NillableClosure!
    
    var validateAllFields:  NillableClosure!
    
    var allFieldsValid: Bool {
        get {
            return registrationValidator.isValidFirstName && registrationValidator.isValidLastName && registrationValidator.isValidPostalCode
        }
    }
    
    func handleTextChanged(fieldTypeTag: USSecondRegistrationFieldType, input: String) {
        switch(fieldTypeTag) {
        case .firstName:
            registrationValidator.firstName = input
            break
        case .lastName:
            registrationValidator.lastName = input
            break
        case .postalCode:
            registrationValidator.postalCode = input
            break
        }
    }
    
    func handleValidationRequest(fieldTypeTag: USSecondRegistrationFieldType) {
        switch(fieldTypeTag) {
        case .firstName:
            validateFirstName?()
            break
        case .lastName:
            validateLastName?()
            break
        case .postalCode:
            validatePostalCode?()
            break
        }
    }
}
