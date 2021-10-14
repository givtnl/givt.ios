//
//  CreditCardControlViewExtension.swift
//  ios
//
//  Created by Mike Pattyn on 13/10/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
import GivtCodeShare

extension CreditCardControlView {
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
        self.endEditing(true)
        if let toolbar = creditCardExpirationDateTextField.inputAccessoryView as? UIToolbar,
           toolbar.items?.contains(where: { item in item == sender }) == true {
//            let expiryDate = viewModel.creditCardValidator.creditCard.expiryDate
//            creditCardExpirationDateTextField.text = "\(String(format: "%02d", selectedMonth))/\(selectedYear)"
//            creditCardExpirationDateTextField.endedEditing()
        }
    }
}
