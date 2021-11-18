//
//  USRegistrationViewControllerEmailAddressExtension.swift
//  ios
//
//  Created by Mike Pattyn on 18/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//
import Foundation

extension USRegistrationViewController {
    func setupEmailAddressField() {
        emailAddressTextField.placeholder = "Email".localized
        
        if let settings = UserDefaults.standard.userExt {
            emailAddressTextField.text = settings.email
            emailAddressTextField.isEnabled = false
        }
    }
}
