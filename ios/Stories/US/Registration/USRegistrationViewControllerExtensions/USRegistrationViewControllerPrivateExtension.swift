//
//  USRegistrationViewControllerPrivateExtension.swift
//  ios
//
//  Created by Mike Pattyn on 14/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import CoreMedia

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
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        self.endEditing()
        if !AppServices.shared.isServerReachable {
            NavigationManager.shared.presentAlertNoConnection(context: self)
            return
        }
        
        SVProgressHUD.show()
        
        guard let userExt = UserDefaults.standard.userExt else { return }
        
        let registerUserCommand = RegisterUserCommand(
            userId: userExt.guid,
            email: userExt.email,
            phoneNumber: viewModel.registrationValidator.phoneNumber,
            password: viewModel.registrationValidator.password,
            appLanguage: Locale.current.languageCode ?? "EN",
            deviceOS: "2",
            country: "US"
        )
        let registerCreditCardCommand = RegisterCreditCardCommand(
            creditCardDetails: CreditCardDetails(
                cardNumber: viewModel.creditCardValidator.creditCard.number!,
                expirationMonth: viewModel.creditCardValidator.creditCard.expiryDate.month as! Int,
                expirationYear:
                    String(viewModel.creditCardValidator.creditCard.expiryDate.year!.stringValue.suffix(2)).toInt 
            )
        )
        
        try? Mediater.shared.sendAsync(request: registerUserCommand, completion: { response in
            if (response.result) {
                LoginManager.shared.loginUser(
                    email: registerUserCommand.email,
                    password: registerUserCommand.password,
                    type: .password, completionHandler: { (success, err, descr) in
                        if success {
                            UserDefaults.standard.amountLimit = 499
                            try? Mediater.shared.sendAsync(request: registerCreditCardCommand, completion: { response in
                                SVProgressHUD.dismiss()
                                if (response.result) {
                                    DispatchQueue.main.async {
                                        UserDefaults.standard.paymentType = .CreditCard
                                        UserDefaults.standard.mandateSigned = true
                                        UserDefaults.standard.isTempUser = false
                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PermissionViewController") as! PermissionViewController
                                        vc.hasBackButton = false
                                        self.show(vc, sender:nil)
                                    }
                                } else {
                                    self.showRegistrationErrorAlert()
                                }
                            })
                        } else {
                            self.showRegistrationErrorAlert()
                        }
                    })
            } else {
                SVProgressHUD.dismiss()
                self.showRegistrationErrorAlert()
            }
        })
    }
    private func showRegistrationErrorAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "SomethingWentWrong".localized,
                message: "ErrorTextRegister".localized,
                preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
