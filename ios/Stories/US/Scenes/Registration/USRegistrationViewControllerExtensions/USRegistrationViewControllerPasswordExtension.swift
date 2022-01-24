//
//  USRegistrationViewControllerPasswordExtension.swift
//  ios
//
//  Created by Mike Pattyn on 18/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//
import Foundation
import UIKit

extension USRegistrationViewController {
    func setupPasswordField() {
        passwordTextField.placeholder = "Password".localized
        passwordHint.text = "PasswordRule".localized
        
        if let passwordField = setPassword {
            passwordTextField.text = passwordField
            passwordTextField.isEnabled = false
            passwordTextField.textColor = UIColor.gray
        }
        passwordTextField.delegate = self
        passwordTextField.tag = USRegistrationFieldType.password.rawValue
        passwordTextField.setRightPaddingPoints(40)
        
        if #available(iOS 12.0, *) {
            passwordTextField.textContentType = .newPassword
        } else {
            passwordTextField.textContentType = .password
        }
        
        passwordTextField.placeholder = "US.Registration.Personal.Details.Password.Placeholder".localized
        createToolbar(passwordTextField)
    }
}
