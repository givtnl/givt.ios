//
//  USSecondRegistrationViewControllerRegisterButtonExtension.swift
//  ios
//
//  Created by Mike Pattyn on 08/12/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import SVProgressHUD

extension USSecondRegistrationViewController {
    func setupRegisterButton() {
        registerButton.setTitle("Register".localized, for: .normal)
        registerButton.setBackgroundColor(color: UIColor.init(rgb: 0xE3E2E7), forState: .disabled)
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        
        SVProgressHUD.show()
        
        self.registerUserCommand.firstName = self.firstNameTextField.text
        self.registerUserCommand.lastName = self.lastNameTextField.text
        self.registerUserCommand.postalCode = self.postalCodeTextField.text
        
        try! Mediater.shared.sendAsync(request: self.registerUserCommand, completion: { response in
            if (response.result) {
                LoginManager.shared.loginUser(email: self.registerUserCommand.email, password: self.registerUserCommand.password, type: .password) { success, error, description in
                    if (success) {
                        try? Mediater.shared.sendAsync(request: self.registerCreditCardByTokenCommand) { response in
                            if response.result {
                                UserDefaults.standard.amountLimit = 25000
                                UserDefaults.standard.paymentType = .CreditCard
                                UserDefaults.standard.mandateSigned = true
                                UserDefaults.standard.isTempUser = false
                                DispatchQueue.main.async {
                                    UserDefaults.standard.paymentType = .CreditCard
                                    UserDefaults.standard.mandateSigned = true
                                    UserDefaults.standard.isTempUser = false
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "PermissionViewController") as! PermissionViewController
                                    vc.hasBackButton = false
                                    self.show(vc, sender:nil)
                                }
                            } else {
                                //show alert
                                print(String(describing: response.error))
                            }
                        }
                    }
                }
            }
        })
    }
}
