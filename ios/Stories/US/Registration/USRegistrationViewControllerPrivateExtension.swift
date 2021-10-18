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
        viewModel.validateAllFields?()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.endEditing()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func faqButtonPressed(_ sender: Any) {
        let vc = UIStoryboard(name: "FAQ", bundle: nil).instantiateInitialViewController() as! FAQViewController
        self.present(vc, animated: true, completion: nil)
    }
}
