//
//  BudgetExternalGivtsControllerExtension.swift
//  ios
//
//  Created by Mike Pattyn on 28/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit

extension BudgetExternalGivtsViewController {
    func setupTerms() {
        labelExternalGivtsInfo.attributedText = createInfoText()
        labelExternalGivtsInfo.textColor = .white
        labelExternalGivtsSubtitle.text = "BudgetExternalGiftsSubTitle".localized
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
        createToolbar(textFieldExternalGivtsTime)
        createToolbar(textFieldExternalGivtsAmount)
        createToolbar(textFieldExternalGivtsOrganisation)
        
        switch UserDefaults.standard.currencySymbol {
        case "£":
            labelExternalGivtsAmountCurrency.text = "pound-sign"
        default:
            labelExternalGivtsAmountCurrency.text = "euro-sign"
        }
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
            .normal("BudgetExternalGiftsInfo".localized, font: UIFont(name: "Avenir-Light", size: 16)!)
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
