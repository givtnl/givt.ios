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
        lastNameTextField.text = "+1"
        lastNameTextField.delegate = self
        lastNameTextField.tag = USSecondRegistrationFieldType.lastName.rawValue
        lastNameTextField.keyboardType = .default
        
        lastNameTextField.textContentType = UITextContentType.familyName
        
        createToolbar(lastNameTextField)
    }
}
