//
//  USSecondRegistrationViewController.swift
//  ios
//
//  Created by Mike Pattyn on 06/12/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
import Mixpanel
import AppCenterAnalytics
import SVProgressHUD

class USSecondRegistrationViewController: UIViewController {
    @IBOutlet weak var bottomScrollViewConstraint: NSLayoutConstraint!
    @IBOutlet var theScrollView: UIScrollView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var firstNameTextField: CustomUITextField!
    @IBOutlet weak var lastNameTextField: CustomUITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    
    var viewModel = USSecondRegistrationViewModel()

    // user details from previous screen
    var registerUserCommand: RegisterUserCommand!
    var registerCreditCardCommand: RegisterCreditCardCommand!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = UIImageView(image: UIImage(imageLiteralResourceName: "givt20h.png"))
        
        SVProgressHUD.dismiss { [self] in
            initViewModel()
            setupUI()
            
            MSAnalytics.trackEvent("US User started second registration")
            Mixpanel.mainInstance().track(event: "US User started second registration")
        }
        
        
        SVProgressHUD.dismiss()
    }
    
}

// Privates
private extension USSecondRegistrationViewController {
    @IBAction func registerPressed(_ sender: Any) {
        
        SVProgressHUD.show()
        
        self.registerUserCommand.firstName = self.firstNameTextField.text
        self.registerUserCommand.lastName = self.lastNameTextField.text
        
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
}

// Infrastructure
extension USSecondRegistrationViewController {
    func setupUI() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        setupFirstNameTextField()
        setupLastNameTextField()
        setupScrollViewFix()
    }
    
    func initViewModel() {
        viewModel.setFirstNameTextField = { [weak self] () in
            DispatchQueue.main.async {
                self?.firstNameTextField.text = self?.viewModel.registrationValidator.firstName
            }
        }
        viewModel.validateFirstName =  { [weak self] () in
            DispatchQueue.main.async {
                if let isValid = self?.viewModel.registrationValidator.isValidFirstName {
                    self?.firstNameTextField.setBorders(isValid)
                }
            }
        }
        viewModel.setLastNameTextField = { [weak self] () in
            DispatchQueue.main.async {
                self?.lastNameTextField.text = self?.viewModel.registrationValidator.lastName
            }
        }
        viewModel.validateLastName =  { [weak self] () in
            DispatchQueue.main.async {
                if let isValid = self?.viewModel.registrationValidator.isValidLastName {
                    self?.lastNameTextField.setBorders(isValid)
                }
            }
        }
        
        viewModel.validateAllFields = { [weak self] () in
            DispatchQueue.main.async {
                if (self?.viewModel.registrationValidator.firstName != "") {
                    self?.viewModel.validateFirstName?()
                }
                if (self?.viewModel.registrationValidator.lastName != "") {
                    self?.viewModel.validateLastName?()
                }
                
                if let areAllFieldsValid = self?.viewModel.allFieldsValid {
                    self?.registerButton.isEnabled = areAllFieldsValid
                }
            }
        }
    }
}
