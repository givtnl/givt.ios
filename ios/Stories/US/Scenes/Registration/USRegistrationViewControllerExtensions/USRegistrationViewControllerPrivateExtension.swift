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

private extension USRegistrationViewController {
    @IBAction func openCreditCardExpiryDatePicker(_ sender: Any) {
        creditCardExpiryDateTextField.becomeFirstResponder()
    }
    
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
            appLanguage: Locale.current.languageCode ?? "en",
            deviceOS: 2,
            country: "US",
            timeZoneId: Calendar.current.timeZone.identifier
        )
        
        let registerCreditCardCommand = RegisterCreditCardCommand(
            creditCardDetails: CreditCardDetails(
                cardNumber: viewModel.creditCardValidator.creditCard.number!,
                expirationMonth: viewModel.creditCardValidator.creditCard.expiryDate.month as! Int,
                expirationYear:
                    String(viewModel.creditCardValidator.creditCard.expiryDate.year!.stringValue.suffix(2)).toInt 
            )
        )
        
        let routeRequest = FromFirstToSecondRegistrationRoute(registerUserCommand: registerUserCommand, registerCreditCardCommand: registerCreditCardCommand)
        
        try! Mediater.shared.send(request: routeRequest, withContext: self)
        
    }
}
