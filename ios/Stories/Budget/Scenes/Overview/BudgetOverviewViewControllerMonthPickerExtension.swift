//
//  BudgetOverviewViewControllerMonthPickerExtension.swift
//  ios
//
//  Created by Mike Pattyn on 26/05/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

extension BudgetOverviewViewController {
    func setupMonthPicker() {
        monthSelectorLabel.text = getFullMonthStringFromDateValue(value: fromMonth).capitalized
    }
    
    private func getMonths() -> [String: Date] {
        let calendar = Calendar.current
        var date = Date()
        var monthStrings: [String: Date] = [date.getMonthNameLong(): date]
        
        while monthStrings.count < 12 {
            date = calendar.date(byAdding: .month, value: -1, to: date)!
            monthStrings[date.getMonthNameLong()] = date
        }
        
        return monthStrings
    }
    
    
    private func createToolbar(_ textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(toolbarDoneButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        textField.inputAccessoryView = toolbar
    }
    
    @objc private func toolbarDoneButtonTapped(_ sender: UIBarButtonItem){
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        if #available(iOS 11.0, *) {
            bottomScrollViewConstraint.constant = keyboardFrame.size.height - view.safeAreaInsets.bottom - 64
        } else {
            bottomScrollViewConstraint.constant = keyboardFrame.size.height - 64
        }
        UIView.animate(withDuration: 0.3, animations: {
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
