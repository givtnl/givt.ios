//
//  USSecondRegistrationViewControllerFirstNameExtension.swift
//  ios
//
//  Created by Mike Pattyn on 06/12/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

extension USSecondRegistrationViewController {
    func setupFirstNameTextField() {
        firstNameTextField.text = "+1"
        firstNameTextField.delegate = self
        firstNameTextField.tag = USSecondRegistrationFieldType.firstName.rawValue
        firstNameTextField.keyboardType = .default
        
        firstNameTextField.textContentType = UITextContentType.givenName
        
        createToolbar(firstNameTextField)
    }
}
