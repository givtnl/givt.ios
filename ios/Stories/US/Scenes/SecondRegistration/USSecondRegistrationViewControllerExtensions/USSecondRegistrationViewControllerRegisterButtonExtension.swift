//
//  USSecondRegistrationViewControllerRegisterButtonExtension.swift
//  ios
//
//  Created by Mike Pattyn on 08/12/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import SVProgressHUD
import GivtCodeShare

extension USSecondRegistrationViewController {
    func setupRegisterButton() {
        registerButton.setTitle("Register".localized, for: .normal)
        registerButton.setBackgroundColor(color: UIColor.init(rgb: 0xE3E2E7), forState: .disabled)
    }
    
    fileprivate func showError() {
        SVProgressHUD.dismiss()
        let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("ErrorTextRegister", comment: ""), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        
        SVProgressHUD.show()
        
        self.registerUserCommand.firstName = self.firstNameTextField.text!
        self.registerUserCommand.lastName = self.lastNameTextField.text!
        self.registerUserCommand.postalCode = self.postalCodeTextField.text!
        
        try! Mediater.shared.sendAsync(request: RegisterUserCommand(registerUserCommandBody: registerUserCommand)) { registrationResult in
            if registrationResult.result {
                LoginManager.shared.loginUser(email: self.registerUserCommand.email, password: self.registerUserCommand.password, type: .password) { loginSuccess, description in
                    if loginSuccess {
                        DispatchQueue.main.async { // Because: 'Calling Kotlin suspend functions from Swift/Objective-C is currently supported only on main thread
                            try? Mediater.shared.sendAsync(request: self.registerCreditCardByTokenCommand) { registerCreditCardByTokenResponse in
                                if registerCreditCardByTokenResponse.result {
                                    DispatchQueue.main.async {
                                        UserDefaults.standard.amountLimit = 25000
                                        UserDefaults.standard.paymentType = .CreditCard
                                        UserDefaults.standard.mandateSigned = true
                                        UserDefaults.standard.isTempUser = false
                                        
                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PermissionViewController") as! PermissionViewController
                                        vc.hasBackButton = false
                                        self.show(vc, sender:nil)
                                    }
                                } else {
                                    //show alert
                                    DispatchQueue.main.async {
                                        self.showError()
                                        LogService.shared.error(message: "Error while registering credit card by token. Reason: \(String(describing: registerCreditCardByTokenResponse.error))")
                                    }
                                }
                            }
                        }
                    } else {
                        //show alert
                        DispatchQueue.main.async {
                            self.showError()
                            LogService.shared.error(message: "Error while logging in user during registration. Reason: \(String(describing: description))")
                        }
                    }
                }
            } else {
                //show alert
                DispatchQueue.main.async {
                    self.showError()
                    LogService.shared.error(message: "Error while registering user. Reason: \(String(describing: registrationResult.error))")
                }
            }
        }
    }
}
