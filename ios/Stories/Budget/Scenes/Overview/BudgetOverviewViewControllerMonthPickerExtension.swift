//
//  BudgetOverviewViewControllerMonthPickerExtension.swift
//  ios
//
//  Created by Mike Pattyn on 26/05/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

extension BudgetOverviewViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func setupMonthPicker() {
        monthPickerData = getMonths().reversed()
        monthPickerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openMonthPicker)))
        
        monthPickerLabel.layer.addBorder(edge: .left, color: ColorHelper.UITextFieldBorderColor, thickness: 0.5)
        monthPickerView.borderColor = ColorHelper.UITextFieldBorderColor
        monthPickerView.borderWidth = 0.5
        
        monthPicker = UIPickerView()
        monthPicker.dataSource = self
        monthPicker.delegate = self
        monthPicker.selectRow(monthPickerData.count - 1, inComponent: 0, animated: false)
        monthPicker.setValue(ColorHelper.GivtPurple, forKeyPath: "textColor")
        monthPicker.tintColor = ColorHelper.GivtPurple
        monthPickerLabel.inputView = monthPicker
        monthPickerLabel.text = monthPickerData.last
        monthPickerLabel.tintColor = .clear
        createToolbar(monthPickerLabel)
        
    }
    
    @objc private func openMonthPicker() {
        print("press works")
    }
    
    private func getMonths() -> [String] {
        let calendar = Calendar.current
        var date = Date()
        var monthStrings: [String] = [date.getMonthNameLong()]
        
        while monthStrings.count < 12 {
            date = calendar.date(byAdding: .month, value: -1, to: date)!
            monthStrings.append(date.getMonthNameLong())
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return monthPickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return monthPickerData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.monthPickerLabel.text = monthPickerData[row]
        monthPicker.reloadAllComponents()
    }
}
