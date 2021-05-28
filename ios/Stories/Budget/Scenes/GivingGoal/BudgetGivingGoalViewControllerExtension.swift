//
//  BudgetGivingGoalViewControllerExtension.swift
//  ios
//
//  Created by Mike Pattyn on 04/05/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import SVProgressHUD
import UIKit

extension BudgetGivingGoalViewController {
    func setupTerms() {
        navBar.title = "BudgetGivingGoalTitle".localized
        infoLabel.attributedText = createInfoText(bold: "BudgetGivingGoalInfoBold", normal: "BudgetGivingGoalInfo")
        amountTitelLabel.text = "BudgetGivingGoalMine".localized
        periodTitelLabel.text = "BudgetGivingGoalTime".localized
        labelRemove.attributedText = "BudgetGivingGoalRemove".localized.underlined
        buttonSave.setTitle("Save".localized, for: .normal)
    }
    func setupUI() {
        
        amountViewLabelCurrency.layer.addBorder(edge: .right, color: ColorHelper.UITextFieldBorderColor, thickness: 0.5)
        amountView.borderColor = ColorHelper.UITextFieldBorderColor
        amountView.borderWidth = 0.5
        createToolbar(amountViewTextField)
        amountViewTextField.keyboardType = .numberPad
        
        periodViewLabelDown.layer.addBorder(edge: .left, color: ColorHelper.UITextFieldBorderColor, thickness: 0.5)
        periodView.borderColor = ColorHelper.UITextFieldBorderColor
        periodView.borderWidth = 0.5
        createToolbar(periodViewTextField)
        
        frequencyPicker = UIPickerView()
        frequencyPicker.dataSource = self
        frequencyPicker.delegate = self
        frequencyPicker.selectRow(0, inComponent: 0, animated: false)
        frequencyPicker.setValue(ColorHelper.GivtPurple, forKeyPath: "textColor")
        frequencyPicker.tintColor = ColorHelper.GivtPurple
        periodViewTextField.inputView = frequencyPicker
        periodViewTextField.text = frequencys[0][1] as? String
        periodViewTextField.tintColor = .clear
        
        if let goal = givingGoal {
            amountViewTextField.text = goal.amount.getFormattedWithoutCurrency(decimals: 0)
            periodViewTextField.text = frequencys[goal.periodicity][1] as? String
            frequencyPicker.selectRow(goal.periodicity, inComponent: 0, animated: false)
        }
    }
    
    @objc func deleteGivingGoal() {
        if !AppServices.shared.isServerReachable {
            try? Mediater.shared.send(request: NoInternetAlert(), withContext: self)
        } else {
            SVProgressHUD.show()
            NavigationManager.shared.executeWithLogin(context: self) {
                try! Mediater.shared.sendAsync(request: DeleteGivingGoalCommand(), completion: { response in
                    DispatchQueue.main.async {
                        if (response as ResponseModel<Bool>).result {
                            try! Mediater.shared.send(request: GoBackOneControllerRoute(), withContext: self)
                        } else {
                            SVProgressHUD.dismiss()
                        }
                    }
                })
            }
        }
    }
    private func createInfoText(bold: String, normal: String) -> NSMutableAttributedString {
        return NSMutableAttributedString()
            .bold(bold.localized + "\n", font: UIFont(name: "Avenir-Black", size: 15)!)
            .normal(normal.localized, font: UIFont(name: "Avenir-Light", size: 15)!)
        
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
    
    func checkFields() {
        var isValid = false
        
        if let amount: Double = amountViewTextField.text?.replacingOccurrences(of: ",", with: ".").doubleValue {
            if amount >= 1 && amount <= 99999 {
                isValid = true
            }
        }
        
        if !isValid {
            amountView.borderColor = .red
        } else {
            amountView.borderColor = ColorHelper.UITextFieldBorderColor
        }
        
        if givingGoal != nil {
            if givingGoal?.periodicity != frequencyPicker.selectedRow(inComponent: 0) || givingGoal?.amount != amountViewTextField.text?.replacingOccurrences(of: ",", with: ".").doubleValue {
                buttonSave.isEnabled = true
            } else {
                buttonSave.isEnabled = false
            }
        } else {
            if amountViewTextField.text != String.empty {
                buttonSave.isEnabled = true
            } else {
                buttonSave.isEnabled = false
            }
        }
    }
}
