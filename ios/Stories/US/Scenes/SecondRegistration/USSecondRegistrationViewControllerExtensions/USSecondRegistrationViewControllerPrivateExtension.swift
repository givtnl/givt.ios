//
//  USSecondRegistrationViewControllerPrivateExtension.swift
//  ios
//
//  Created by Mike Pattyn on 06/12/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import SVProgressHUD
import Algorithms

private extension USSecondRegistrationViewController {

    @IBAction func registerPressed(_ sender: Any) {
        try! Mediater.shared.sendAsync(request: self.registerUserCommand, completion: { response in
            if (response.result) {
                LoginManager.shared.loginUser(email: self.registerUserCommand.email, password: self.registerUserCommand.password, type: .password) { success, error, description in
                    if (success) {
                        try? Mediater.shared.sendAsync(request: self.registerCreditCardCommand, completion: { response in
                            UserDefaults.standard.amountLimit = 499
                            UserDefaults.standard.paymentType = .CreditCard
                            UserDefaults.standard.mandateSigned = true
                            UserDefaults.standard.isTempUser = false
                            if (response.result) {
                                DispatchQueue.main.async {
                                    UserDefaults.standard.paymentType = .CreditCard
                                    UserDefaults.standard.mandateSigned = true
                                    UserDefaults.standard.isTempUser = false
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "PermissionViewController") as! PermissionViewController
                                    vc.hasBackButton = false
                                    self.show(vc, sender:nil)
                                }
                            }
                        })
                    }
                }
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
