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
import WebKit

class USRegistrationViewController : UIViewController {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bottomScrollViewConstraint: NSLayoutConstraint!
    @IBOutlet var theScrollView: UIScrollView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var creditCardWebView: WKWebView!
    
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
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainView.isHidden = true
        showLoader()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = UIImageView(image: UIImage(imageLiteralResourceName: "givt20h.png"))
                
        Analytics.trackEvent("US User started registration")
        Mixpanel.mainInstance().track(event: "US User started registration")
        
        initViewModel()
        setupUI()
    }
    
    func initViewModel() {
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
                if let areAllFieldsValid = self?.viewModel.allFieldsValid,
                   let termsChecked = self?.termsCheckBox.isSelected {
                    self?.nextButton.isEnabled = areAllFieldsValid && termsChecked
                }
            }
        }
    }
}
