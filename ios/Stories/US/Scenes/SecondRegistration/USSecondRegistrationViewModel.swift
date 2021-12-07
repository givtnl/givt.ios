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
    
    var validateFirstName: NillableClosure!
    var validateLastName: NillableClosure!
    
    var setFirstNameTextField:  NillableClosure!
    var setLastNameTextField:  NillableClosure!
    
    var validateAllFields:  NillableClosure!
    
    var allFieldsValid: Bool {
        get {
            return registrationValidator.isValidFirstName && registrationValidator.isValidLastName
        }
    }
    
    func handleTextChanged(fieldTypeTag: USSecondRegistrationFieldType, input: String) {
        switch(fieldTypeTag) {
        case .firstName:
            registrationValidator.firstName = input
            setFirstNameTextField?()
            break
        case .lastName:
            registrationValidator.lastName = input
            setLastNameTextField?()
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
        }
    }
}
