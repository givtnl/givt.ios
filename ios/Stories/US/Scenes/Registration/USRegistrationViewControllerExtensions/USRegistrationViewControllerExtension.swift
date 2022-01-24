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
        
        showLoader()
        tokenize()
    }
    
    func handleTokenizeFinished(token: String) {
        guard let userExt = UserDefaults.standard.userExt else { return }

        let registerUserCommand = RegisterUserCommand(
            userId: userExt.guid,
            email: userExt.email,
            phoneNumber: viewModel.registrationValidator.phoneNumber,
            password: viewModel.registrationValidator.password,
            appLanguage: Locale.current.languageCode ?? "en",
            deviceOS: 2,
            country: "US",
            timeZoneId: Calendar.current.timeZone.identifier
        )

        let registerCreditCardByTokenCommand = RegisterCreditCardByTokenCommand(userId: userExt.guid, PaymentMethodToken: token)

        let routeRequest = FromFirstToSecondRegistrationRoute(registerUserCommand: registerUserCommand, registerCreditCardByTokenCommand: registerCreditCardByTokenCommand)

        try! Mediater.shared.sendAsync(request: routeRequest, withContext: self) {
            self.hideLoader()
        }
    }
}
