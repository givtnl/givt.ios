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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)

        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
                
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
        viewModel.setValues(
            phoneNumber: "+1111111111",
            password: "Test123"
        )
        termsCheckBox.isSelected = true
        viewModel.validateAllFields?()
        #endif
    }
    // MARK: Scrollview
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
        let keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        theScrollView.contentInset.bottom = contentInsets.bottom - 40
        theScrollView.scrollIndicatorInsets.bottom = contentInsets.bottom - 40
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        theScrollView.contentInset = .zero
        theScrollView.scrollIndicatorInsets = .zero
    }
}
