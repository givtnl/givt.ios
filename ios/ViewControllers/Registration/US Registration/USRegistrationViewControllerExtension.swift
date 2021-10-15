//
//  USRegistrationViewControllerExtension.swift
//  ios
//
//  Created by Mike Pattyn on 14/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import GivtCodeShare

extension USRegistrationViewController {
    func setupUI() {
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
        
        setupCreditCardControl()
        setupPhoneNumberField()
        setupEmailAddressField()
        setupPasswordField()
        setupTerms()
        setupBackButton()
        setupNextButton()
        setupTitle()
        setupDebug()

        setupScrollViewFix()
    }
    // MARK: Creditcard
    func setupCreditCardControl() {
        NSLayoutConstraint.activate([
            creditCardControl.contentView.topAnchor.constraint(equalTo: creditCardControl.topAnchor),
            creditCardControl.contentView.bottomAnchor.constraint(equalTo: creditCardControl.bottomAnchor),
            creditCardControl.contentView.leadingAnchor.constraint(equalTo: creditCardControl.leadingAnchor),
            creditCardControl.contentView.trailingAnchor.constraint(equalTo: creditCardControl.trailingAnchor)
        ])
    }
    // MARK: Phone number
    func setupPhoneNumberField() {
        phoneNumberTextField.placeholder = "+1"
        phoneNumberTextField.delegate = self
        phoneNumberTextField.tag = USRegistrationFieldType.phoneNumber.rawValue
        phoneNumberTextField.keyboardType = .phonePad
    }
    // MARK: Email address
    func setupEmailAddressField() {
        emailAddressTextField.placeholder = "Email".localized
        
        if let settings = UserDefaults.standard.userExt {
            emailAddressTextField.text = settings.email
            emailAddressTextField.isEnabled = false
        }
        emailAddressTextField.keyboardType = .emailAddress
        emailAddressTextField.delegate = self
        emailAddressTextField.tag = USRegistrationFieldType.emailAddress.rawValue
    }
    // MARK: Password
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

    }
    // MARK: Terms
    func setupTerms() {
        let attachment: NSTextAttachment = NSTextAttachment()
        attachment.image = #imageLiteral(resourceName: "littleinfo.png")
        attachment.bounds = CGRect(x: 0, y: -4, width: (attachment.image?.size.width)!, height: (attachment.image?.size.height)!)
        let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
        let myString:NSMutableAttributedString = NSMutableAttributedString(string: "AcceptPolicy".localized + " ")
        myString.append(attachmentString)
        
        saveMyData.attributedText = myString
        saveMyData.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openTerms)))
        saveMyData.isUserInteractionEnabled = true
    }
    
    @objc func openTerms() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
        vc.typeOfTerms = .privacyPolicy
        self.present(vc, animated: true, completion: {
            print("done terms")
        })
    }
    // MARK: Navigation
    func setupBackButton() {
        backButton.accessibilityLabel = "Back".localized
    }
    func setupNextButton() {
        nextButton.setTitle("Next".localized, for: .normal)
        nextButton.setBackgroundColor(color: UIColor.init(rgb: 0xE3E2E7), forState: .disabled)
    }
    func setupTitle() {
        titleText.text = "RegisterPage".localized
    }
    // MARK: Debug - prefill
    func setupDebug() {
        #if DEBUG
        viewModel.creditCardViewModel.setValues(
            cardNumber: "370000000000002",
            expiryDate: "0330",
            securityCode: "7373"
        )
        viewModel.setValues(
            phoneNumber: "+1111111111",
            emailAddress: "testen@givtapp.net",
            password: "Test123"
        )

        termsCheckBox.isSelected = true
        #endif
    }
    // MARK: Scrollview
    func setupScrollViewFix() {
        // Prevents the scroll view from swallowing up the touch event of child buttons
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tapGesture.cancelsTouchesInView = false
        theScrollView.addGestureRecognizer(tapGesture)
    }
}
