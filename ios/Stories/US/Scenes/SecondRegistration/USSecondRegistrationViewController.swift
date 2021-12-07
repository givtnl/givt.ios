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
    }
}

// Infrastructure
extension USSecondRegistrationViewController {
    func setupUI() {
        setupFirstNameTextField()
        setupLastNameTextField()
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
                self?.firstNameTextField.text = self?.viewModel.registrationValidator.firstName
            }
        }
        viewModel.setLastNameTextField =  { [weak self] () in
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
