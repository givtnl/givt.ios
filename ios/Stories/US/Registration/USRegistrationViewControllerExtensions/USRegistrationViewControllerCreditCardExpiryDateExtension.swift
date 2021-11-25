//
//  USRegistrationViewControllerCreditCardExpiryDateExtension.swift
//  ios
//
//  Created by Mike Pattyn on 18/11/2021.
//  Copyright © 2021 Givt. All rights reserved.
//
import Foundation
import UIKit
import MonthYearPicker

extension USRegistrationViewController {
    func setupExpiryDate() {

        creditCardExpiryDatePicker = MonthYearPickerView(frame: CGRect(origin: CGPoint(x: 0, y: (view.bounds.height - 216) / 2), size: CGSize(width: view.bounds.width, height: 216)))
        creditCardExpiryDatePicker.date = Calendar.current.date(byAdding: DateComponents(year: 1), to: Date())!
        creditCardExpiryDatePicker.addTarget(self, action: #selector(handleExpiryDateChanged(_:)), for: .valueChanged)
        creditCardExpiryDateTextField.inputView = creditCardExpiryDatePicker
        
        creditCardExpiryDateTextField.tag = USRegistrationFieldType.creditCardExpiryDate.rawValue
        creditCardExpiryDateTextField.delegate = self
        
        creditCardExpiryDateTextField.textContentType = UITextContentType.expiryDate
        createToolbar(creditCardExpiryDateTextField)
    }
    @objc func handleExpiryDateChanged(_ sender: MonthYearPickerView){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        creditCardExpiryDateTextField.text = dateFormatter.string(from: sender.date)
    }
}
