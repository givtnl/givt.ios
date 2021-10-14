//
//  USRegistrationViewControllerPrivateExtension.swift
//  ios
//
//  Created by Mike Pattyn on 14/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

extension USRegistrationViewController {
    @IBAction func passwordTextFieldSetVisible(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        passwordTextField.isSecureTextEntry = !sender.isSelected
    }

    @IBAction func termsCheckBox(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
}
