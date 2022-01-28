//
//  USSecondRegistrationViewControllerPostalCodeExtension.swift
//  ios
//
//  Created by Mike Pattyn on 28/01/2022.
//  Copyright © 2022 Givt. All rights reserved.
//

import Foundation
import UIKit
extension USSecondRegistrationViewController {
    func setupPostalCodeTextField() {
        postalCodeTextField.delegate = self
        postalCodeTextField.tag = USSecondRegistrationFieldType.postalCode.rawValue
        postalCodeTextField.keyboardType = .phonePad
        postalCodeTextField.textContentType = UITextContentType.postalCode
        postalCodeTextField.placeholder = "US.Registration.Personal.Details.PostalCode.Placeholder".localized
        createToolbar(postalCodeTextField)
    }
}
