//
//  USRegistrationViewControllerCreditCardExpiryDateExtension.swift
//  ios
//
//  Created by Mike Pattyn on 18/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//
import Foundation
import UIKit

extension USRegistrationViewController {
    func setupExpiryDate() {
        creditCardExpiryDatePicker = UIDatePicker()
        creditCardExpiryDatePicker.datePickerMode = .date
        creditCardExpiryDatePicker.addTarget(self, action: #selector(handleExpiryDateChanged(sender:)), for: .valueChanged)
        creditCardExpiryDateTextField.inputView = creditCardExpiryDatePicker
        
        creditCardExpiryDateTextField.tag = USRegistrationFieldType.creditCardExpiryDate.rawValue
        creditCardExpiryDateTextField.delegate = self
        createToolbar(creditCardExpiryDateTextField)
    }
    @objc func handleExpiryDateChanged(sender: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yyyy"
        creditCardExpiryDateTextField.text = dateFormatter.string(from: sender.date)
    }
}
