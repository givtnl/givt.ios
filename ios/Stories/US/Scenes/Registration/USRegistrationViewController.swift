//
//  USViewController.swift
//  ios
//
//  Created by Mike Pattyn on 14/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import UIKit
import SVProgressHUD
import AppCenterAnalytics
import Mixpanel
import GivtCodeShare
import MonthYearPicker

class USRegistrationViewController : UIViewController {
    @IBOutlet weak var bottomScrollViewConstraint: NSLayoutConstraint!
    @IBOutlet var theScrollView: UIScrollView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    // MARK: Creditcard
        // MARK: Card number
    @IBOutlet weak var creditCardNumberView: UIView!
    @IBOutlet weak var creditCardCompanyLogoImageView: UIImageView!
    @IBOutlet weak var creditCardNumberTextField: CustomUITextField!
        // MARK: Expiry date
    @IBOutlet weak var creditCardExpiryDateTextField: CustomUITextField!

    @IBOutlet weak var creditCardCVVTextField: CustomUITextField!
    // MARK: Phone number
    @IBOutlet weak var phoneNumberTextField: CustomUITextField!
    
    // MARK: Email address
    @IBOutlet weak var emailAddressTextField: CustomUITextField!
    
    // MARK: Password
    @IBOutlet weak var passwordTextField: CustomUITextField!
    @IBOutlet weak var passwordTextFieldVisible: UIButton!
        
    var setPassword: String? = nil
    
    // MARK: Terms permission
    @IBOutlet weak var termsCheckBox: UIButton!
    
    var viewModel = USRegistrationViewModel()
    
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var saveMyData: UILabel!
    @IBOutlet var passwordHint: UILabel!
    @IBOutlet var titleText: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = UIImageView(image: UIImage(imageLiteralResourceName: "givt20h.png"))

        MSAnalytics.trackEvent("US User started registration")
        Mixpanel.mainInstance().track(event: "US User started registration")
        
        initViewModel()
        setupUI()
        
    }
    
    func initViewModel() {
        viewModel.setCardNumberTextField = { [weak self] () in
            DispatchQueue.main.async {
                self?.creditCardNumberTextField.text = self?.viewModel.creditCardValidator.creditCard.formatted
            }
        }
        viewModel.setCreditCardCompanyLogo = { [weak self ]() in
            DispatchQueue.main.async {
                let creditCardCompany = self?.viewModel.creditCardValidator.creditCard.company
                self?.creditCardCompanyLogoImageView.image = CreditCardHelper.getCreditCardCompanyLogo(creditCardCompany ?? CreditCardCompany.undefined)
            }
        }
        viewModel.setExpiryTextField = { [weak self] () in
            DispatchQueue.main.async {
                self?.creditCardExpiryDateTextField.text = self?.viewModel.creditCardValidator.creditCard.expiryDate.formatted
            }
        }
        viewModel.setCVVTextField = { [weak self] () in
            DispatchQueue.main.async {
                self?.creditCardCVVTextField.text = self?.viewModel.creditCardValidator.creditCard.securityCode
            }
        }
        viewModel.validateCardNumber =  { [weak self] () in
            DispatchQueue.main.async {
                if let isValid = self?.viewModel.creditCardValidator.cardNumberIsValid() {
                    self?.creditCardNumberView.setBorders(isValid)
                }
            }
        }
        viewModel.validateExpiryDate = { [weak self] () in
            if self?.creditCardExpiryDateTextField.text?.count ?? 0 >= 4 {
                DispatchQueue.main.async {
                    if let isValid = self?.viewModel.creditCardValidator.expiryDateIsValid() {
                        self?.creditCardExpiryDateTextField.setBorders(isValid)
                    }
                }
            }
        }
        viewModel.validateSecurityCode = { [weak self] () in
            DispatchQueue.main.async {
                if let isValid = self?.viewModel.creditCardValidator.securityCodeIsValid() {
                    self?.creditCardCVVTextField.setBorders(isValid)
                }
            }
        }
        viewModel.setPasswordTextField = { [weak self] () in
            DispatchQueue.main.async {
                self?.passwordTextField.text = self?.viewModel.registrationValidator.password
            }
        }
        viewModel.setPhoneNumberTextField = { [weak self] () in
            DispatchQueue.main.async {
                self?.phoneNumberTextField.text = self?.viewModel.registrationValidator.phoneNumber
            }
        }
        
        viewModel.updateView = { [weak self] () in
            DispatchQueue.main.async {
                self?.viewModel.setPasswordTextField?()
                self?.viewModel.setPhoneNumberTextField?()
                self?.viewModel.setExpiryTextField?()
                self?.viewModel.setCardNumberTextField?()
                self?.viewModel.setCVVTextField?()
            }
        }
        
        viewModel.validatePassword = { [weak self] () in
            DispatchQueue.main.async {
                if let isValid = self?.viewModel.registrationValidator.isValidPassword {
                    self?.passwordTextField.setBorders(isValid)
                }
            }
        }
        
        viewModel.validatePhoneNumber = { [weak self] () in
            DispatchQueue.main.async {
                if let isValid = self?.viewModel.registrationValidator.isValidPhoneNumber {
                    self?.phoneNumberTextField.setBorders(isValid)
                }
            }
        }

        viewModel.validateAllFields = { [weak self] () in
            DispatchQueue.main.async {
                if (self?.viewModel.registrationValidator.phoneNumber != "") {
                    self?.viewModel.validatePhoneNumber?()
                }
                if (self?.viewModel.registrationValidator.password != "") {
                    self?.viewModel.validatePassword?()
                }
                if (self?.viewModel.creditCardValidator.creditCard.number != nil) {
                    self?.viewModel.validateCardNumber?()
                }
                if (self?.viewModel.creditCardValidator.creditCard.expiryDate.rawValue != "") {
                    self?.viewModel.validateExpiryDate?()
                }
                if (self?.viewModel.creditCardValidator.creditCard.securityCode != nil) {
                    self?.viewModel.validateSecurityCode?()
                }
                
                if let areAllFieldsValid = self?.viewModel.allFieldsValid,
                   let termsChecked = self?.termsCheckBox.isSelected {
                    self?.nextButton.isEnabled = areAllFieldsValid && termsChecked
                }
            }
        }
    }
}
