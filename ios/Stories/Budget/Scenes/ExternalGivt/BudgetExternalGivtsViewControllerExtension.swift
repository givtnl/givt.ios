//
//  BudgetExternalGivtsControllerExtension.swift
//  ios
//
//  Created by Mike Pattyn on 28/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import SVProgressHUD
import UIKit

extension BudgetExternalGivtsViewController {
    func setupTerms() {
        labelExternalGivtsInfo.attributedText = createInfoText()
        labelExternalGivtsInfo.textColor = .white
        labelExternalGivtsSubtitle.text = "BudgetExternalGiftsSubTitle".localized
        navBar.title = "BudgetExternalGiftsSubTitle".localized
        labelExternalGivtsOrganisation.text = "BudgetExternalGiftsOrg".localized
        labelExternalGivtsTime.text = "BudgetExternalGiftsTime".localized
        labelExternalGivtsAmount.text = "BudgetExternalGiftsAmount".localized
        buttonExternalGivtsAdd.setTitle("BudgetExternalGiftsAdd".localized, for: .normal)
        buttonExternalGivtsSave.setTitle("BudgetExternalGiftsSave".localized, for: .normal)

    }
    func setupUI() {
        labelExternalGivtsTimeDown.layer.addBorder(edge: .left, color: ColorHelper.UITextFieldBorderColor, thickness: 0.5)
        viewExternalGivtsTime.borderColor = ColorHelper.UITextFieldBorderColor
        viewExternalGivtsTime.borderWidth = 0.5
        
        labelExternalGivtsAmountCurrency.layer.addBorder(edge: .right, color: ColorHelper.UITextFieldBorderColor, thickness: 0.5)
        viewExternalGivtsAmount.borderColor = ColorHelper.UITextFieldBorderColor
        viewExternalGivtsAmount.borderWidth = 0.5
        
        frequencyPicker = UIPickerView()
        frequencyPicker.dataSource = self
        frequencyPicker.delegate = self
        frequencyPicker.selectRow(0, inComponent: 0, animated: false)
        frequencyPicker.setValue(ColorHelper.GivtPurple, forKeyPath: "textColor")
        frequencyPicker.tintColor = ColorHelper.GivtPurple
        textFieldExternalGivtsTime.inputView = frequencyPicker
        textFieldExternalGivtsTime.text = frequencys[0][1] as? String
        textFieldExternalGivtsTime.tintColor = .clear
        
        textFieldExternalGivtsAmount.keyboardType = .decimalPad
        
        createToolbar(textFieldExternalGivtsTime)
        createToolbar(textFieldExternalGivtsAmount)
        createToolbar(textFieldExternalGivtsOrganisation)
        
        switch UserDefaults.standard.currencySymbol {
            case "£":
                labelExternalGivtsAmountCurrency.text = "pound-sign"
            default:
                labelExternalGivtsAmountCurrency.text = "euro-sign"
        }
        
        buttonExternalGivtsSave.isEnabled = false
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
    
    private func createInfoText() -> NSMutableAttributedString {
        return NSMutableAttributedString()
            .bold("BudgetExternalGiftsInfoBold".localized + "\n", font: UIFont(name: "Avenir-Black", size: 16)!)
            .normal("BudgetTooltipExternalGifts".localized, font: UIFont(name: "Avenir-Light", size: 16)!)
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
    func loadDonations() {
        originalStackviewHeightConstant = stackViewEditRowsHeight.constant
        
        externalDonations = try? Mediater.shared.send(request: GetAllExternalDonationsQuery()).result
        
        externalDonations!.forEach { model in
            let newRow = BudgetExternalGivtsEditRow(id: model.id, description: model.description, amount: model.amount)
            newRow.editButton.addTarget(self, action: #selector(editButtonRow), for: .touchUpInside)
            newRow.deleteButton.addTarget(self, action: #selector(deleteButtonRow), for: .touchUpInside)
            stackViewEditRows.addArrangedSubview(newRow)
        }
        
        if let currentObjectInEditMode = currentObjectInEditMode {
            let model = externalDonations!.filter{$0.id == currentObjectInEditMode}.first!
            modelBeeingEdited = model
            
            textFieldExternalGivtsOrganisation.text = modelBeeingEdited?.description
            textFieldExternalGivtsAmount.text = modelBeeingEdited?.amount.getFormattedWithoutCurrency(decimals: 2)
            
            frequencyPicker.selectRow(getFrequencyFrom(cronExpression: modelBeeingEdited!.cronExpression).rawValue, inComponent: 0, animated: false)
            textFieldExternalGivtsTime.text = frequencys[getFrequencyFrom(cronExpression: model.cronExpression).rawValue][1] as? String
            
            isEditMode = false
            switchButtonState()
            
            buttonExternalGivtsAdd.isEnabled = false
            viewExternalGivtsTime.isEnabled = false
        }
        
        stackViewEditRowsHeight.constant += CGFloat(externalDonations!.count) * 44
        stackViewEditRowsHeight.constant += CGFloat(externalDonations!.count - 1) * 10
    }
    
    func getFrequencyFrom(cronExpression: String) -> ExternalDonationFrequency {
        if cronExpression.split(separator: " ").count != 5 {
            return .Once
        }
        
        let splittedCron = cronExpression.split(separator: " ")
        
        if splittedCron[3].contains("/") {
            let frequencyInt = Int(splittedCron[3].split(separator: "/")[1])!
            switch frequencyInt {
                case 1:
                    return .Monthly
                case 3:
                    return .Quarterly
                case 6:
                    return .HalfYearly
                case 12:
                    return .Yearly
                default:
                    return .Once
            }
        }
        return .Once
    }

    @objc func deleteButtonRow(_ sender: UIButton) {
        SVProgressHUD.show()

        let editRow = getEditRowFrom(button: sender)
        
        let command = DeleteExternalDonationCommand(guid: editRow.id!)
        
        NavigationManager.shared.executeWithLogin(context: self) {
            let _ = try? Mediater.shared.send(request: command)
            self.resetFields()
            self.reloadExternalDonationList()
        }
        
        resetButtonState()
        SVProgressHUD.dismiss()
    }
    
    @objc func editButtonRow(_ sender: UIButton) {
        switchButtonState(editmode: true)
        
        let editRow = getEditRowFrom(button: sender)
        currentObjectInEditMode = editRow.id!
        
        let model = externalDonations!.filter{$0.id == editRow.id!}.first!
        modelBeeingEdited = model
        
        textFieldExternalGivtsOrganisation.text = modelBeeingEdited!.description
        textFieldExternalGivtsAmount.text = modelBeeingEdited!.amount.getFormattedWithoutCurrency(decimals: 2)
        
        frequencyPicker.selectRow(getFrequencyFrom(cronExpression: modelBeeingEdited!.cronExpression).rawValue, inComponent: 0, animated: false)
        textFieldExternalGivtsTime.text = frequencys[getFrequencyFrom(cronExpression: modelBeeingEdited!.cronExpression).rawValue][1] as? String
        
        buttonExternalGivtsAdd.isEnabled = false
        viewExternalGivtsTime.isEnabled = false
    }
    
    private func getEditRowFrom(button: UIButton) -> BudgetExternalGivtsEditRow {
        return button.superview?.superview?.superview?.superview as! BudgetExternalGivtsEditRow
    }
    


    func checkFields() {
        var isAmountValid = false
        var isDescriptionValid = false
        
        if let model = modelBeeingEdited {
            let description = textFieldExternalGivtsOrganisation.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if description.count > 30 || description == String.empty {
                setBorder(textField: textFieldExternalGivtsOrganisation, color: UIColor.red)
                isDescriptionValid = false
            } else {
                resetBorder(textField: textFieldExternalGivtsOrganisation)
                isDescriptionValid = true
            }
            var amount: Double = 0
            
            if textFieldExternalGivtsAmount.text!.count != 0 {
                amount = Double(textFieldExternalGivtsAmount.text!.replacingOccurrences(of: ",", with: ".")) ?? 0
            }
            
            if amount == 0 || amount > 99999 {
                setBorder(view: viewExternalGivtsAmount)
                isAmountValid = false
            } else {
                resetBorder(view: viewExternalGivtsAmount)
                isAmountValid = true
            }
            
            if isAmountValid && isDescriptionValid && amount != model.amount || description != model.description {
                buttonExternalGivtsAdd.isEnabled = true
            } else {
                buttonExternalGivtsAdd.isEnabled = false
            }
            
        } else {
            
            let description = textFieldExternalGivtsOrganisation.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if description.count > 30 || description == String.empty {
                setBorder(textField: textFieldExternalGivtsOrganisation, color: UIColor.red)
                isDescriptionValid = false
            } else {
                resetBorder(textField: textFieldExternalGivtsOrganisation)
                isDescriptionValid = true
            }
            
            if textFieldExternalGivtsAmount.text!.count != 0 {
                let amount: Double = Double(textFieldExternalGivtsAmount.text!.replacingOccurrences(of: ",", with: ".")) ?? 0
                if amount == 0 || amount > 99999 {
                    setBorder(view: viewExternalGivtsAmount)
                    isAmountValid = false
                } else {
                    resetBorder(view: viewExternalGivtsAmount)
                    isAmountValid = true
                }
            }
            
            if isAmountValid && isDescriptionValid {
                buttonExternalGivtsAdd.isEnabled = true
            } else {
                buttonExternalGivtsAdd.isEnabled = false
            }
        }
    }
    func setBorder(textField: UITextField, color: UIColor) {
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = color.cgColor
        textField.layer.borderWidth = 1.0
    }
    
    func setBorder(view: BudgetExternalGivtsViewWithBorder) {
        view.borderColor = UIColor.red
        view.borderWidth = 1
    }
    
    func resetBorder(textField: UITextField) {
        textField.layer.cornerRadius = 0
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.layer.borderWidth = 0
    }
    
    func resetBorder(view: BudgetExternalGivtsViewWithBorder) {
        view.borderColor = ColorHelper.UITextFieldBorderColor
        view.borderWidth = 0.5
    }
    
    func switchButtonState(editmode: Bool = false) {
        if editmode {
            isEditMode = true
            buttonExternalGivtsAdd.setTitle("Edit", for: .normal)
            return
        }
        if isEditMode {
            isEditMode = false
            buttonExternalGivtsAdd.setTitle("Add", for: .normal)
        } else {
            isEditMode = true
            buttonExternalGivtsAdd.setTitle("Edit", for: .normal)
        }
    }
    
    func resetButtonState() {
        isEditMode = false
        buttonExternalGivtsAdd.setTitle("Add", for: .normal)
    }
    
    func resetFields() {
        textFieldExternalGivtsOrganisation.text = String.empty
        textFieldExternalGivtsAmount.text = String.empty
        frequencyPicker.selectRow(0, inComponent: 0, animated: false)
        textFieldExternalGivtsTime.text = frequencys[0][1] as? String
        buttonExternalGivtsAdd.isEnabled = false
    }
    
    func reloadExternalDonationList() {
        externalDonations = try? Mediater.shared.send(request: GetAllExternalDonationsQuery()).result
        
        stackViewEditRows.arrangedSubviews.forEach { arrangedSubview in
            arrangedSubview.removeFromSuperview()
        }
        
        stackViewEditRowsHeight.constant = originalStackviewHeightConstant!
        
        externalDonations!.forEach { model in
            let newRow = BudgetExternalGivtsEditRow(id: model.id, description: model.description, amount: model.amount)
            newRow.editButton.addTarget(self, action: #selector(editButtonRow), for: .touchUpInside)
            newRow.deleteButton.addTarget(self, action: #selector(deleteButtonRow), for: .touchUpInside)
            stackViewEditRows.addArrangedSubview(newRow)
        }
        
        stackViewEditRowsHeight.constant += CGFloat(externalDonations!.count) * 44
        stackViewEditRowsHeight.constant += CGFloat(externalDonations!.count - 1) * 10
    }
}
