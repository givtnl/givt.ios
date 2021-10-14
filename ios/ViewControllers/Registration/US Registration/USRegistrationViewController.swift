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

class USRegistrationViewController : UIViewController {
    @IBOutlet var theScrollView: UIScrollView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    // MARK: Creditcard
    @IBOutlet var creditCardControl: CreditCardControlView!
    
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
    private var _lastTextField: UITextField = UITextField()
    private var validationHelper = ValidationHelper.shared
    private var _isShowingPassword = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = UIImageView(image: UIImage(imageLiteralResourceName: "givt20h.png"))

        MSAnalytics.trackEvent("US User started registration")
        Mixpanel.mainInstance().track(event: "US User started registration")
        
        initViewModel()
        setupUI()
        
        viewModel.validateAllFields?()
    }
    
    func initViewModel() {
        viewModel.creditCardViewModel = creditCardControl.viewModel
        
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
        viewModel.setEmailAddressTextField = { [weak self] () in
            DispatchQueue.main.async {
                self?.emailAddressTextField.text = self?.viewModel.registrationValidator.emailAddress
            }
        }
        
        
        viewModel.updateView = { [weak self] () in
            DispatchQueue.main.async {
                self?.viewModel.setPasswordTextField?()
                self?.viewModel.setPhoneNumberTextField?()
                self?.viewModel.setEmailAddressTextField?()
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
        viewModel.validateEmailAddress = { [weak self] () in
            DispatchQueue.main.async {
                if let isValid = self?.viewModel.registrationValidator.isValidEmail {
                    self?.passwordTextField.setBorders(isValid)
                }
            }
        }
        viewModel.validateAllFields = { [weak self] () in
            DispatchQueue.main.async {
                self?.viewModel.validatePhoneNumber?()
                self?.viewModel.validateEmailAddress?()
                self?.viewModel.validatePassword?()
                self?.viewModel.creditCardViewModel.validateCardNumber?()
                self?.viewModel.creditCardViewModel.validateExpiryDate?()
                self?.viewModel.creditCardViewModel.validateSecurityCode?()
                if let areAllFieldsValid = self?.viewModel.allFieldsValid {
                    self?.nextButton.isEnabled = areAllFieldsValid
                }
            }
        }
    }
}
