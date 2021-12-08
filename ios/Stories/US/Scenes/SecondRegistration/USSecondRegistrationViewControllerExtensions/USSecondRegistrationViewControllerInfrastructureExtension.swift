//
//  USSecondRegistrationViewControllerInfrastructureExtension.swift
//  ios
//
//  Created by Mike Pattyn on 06/12/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

extension USSecondRegistrationViewController {
    func setupUI() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        setupFirstNameTextField()
        setupLastNameTextField()
        setupScrollViewFix()
        setupBackButton()
        setupRegisterButton()
        
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
    
    func setupScrollViewFix() {
        // Prevents the scroll view from swallowing up the touch event of child buttons
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tapGesture.cancelsTouchesInView = false
        theScrollView.addGestureRecognizer(tapGesture)
    }
    
    func createToolbar(_ textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(toolbarDoneButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        textField.inputAccessoryView = toolbar
    }
    
    @objc func toolbarDoneButtonTapped(_ sender: UIBarButtonItem){
        self.endEditing()
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        bottomScrollViewConstraint.constant = keyboardFrame.size.height - view.safeAreaInsets.bottom - 64
        
        UIView.animate(withDuration: 0.3, animations: {
            self.theScrollView.scrollToBottom()
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        bottomScrollViewConstraint.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
}
