//
//  USSecondRegistrationViewControllerLastNameExtension.swift
//  ios
//
//  Created by Mike Pattyn on 06/12/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

extension USSecondRegistrationViewController {
    func setupLastNameTextField() {
        lastNameTextField.delegate = self
        lastNameTextField.tag = USSecondRegistrationFieldType.lastName.rawValue
        lastNameTextField.keyboardType = .default
        lastNameTextField.placeholder = "US.Registration.Personal.Details.Lastname.Placeholder".localized

        lastNameTextField.textContentType = UITextContentType.familyName
        
        createToolbar(lastNameTextField)
    }
}
