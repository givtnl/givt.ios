//
//  BudgetExternalGivtsPrivateExtension.swift
//  ios
//
//  Created by Mike Pattyn on 01/03/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import SVProgressHUD
import UIKit

private extension BudgetExternalGivtsViewController {
    @IBAction func backButton(_ sender: Any) {
        if !AppServices.shared.isServerReachable {
            try? Mediater.shared.send(request: NoInternetAlert(), withContext: self)
        } else {
            try? Mediater.shared.send(request: GoBackToSummaryRoute(needsReload: somethingHappened), withContext: self)
        }
    }
    
    @IBAction func buttonSave(_ sender: Any) {
        if !AppServices.shared.isServerReachable {
            try? Mediater.shared.send(request: NoInternetAlert(), withContext: self)
        } else {
            try? Mediater.shared.send(request: GoBackToSummaryRoute(needsReload: somethingHappened), withContext: self)
        }
    }

    @IBAction func timeTapped(_ sender: Any) {
        textFieldExternalGivtsTime.becomeFirstResponder()
    }
    func alertToLongName() {
        let alert = UIAlertController(
            title: "BudgetExternalDonationToLongAlertTitle".localized,
            message: "BudgetExternalDonationToLongAlertMessage".localized,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in }))
        
        self.present(alert, animated: true, completion:  {})
    }
    
    func alertToHighAmount() {
        let alert = UIAlertController(
            title: "BudgetExternalDonationToHighAlertTitle".localized,
            message: "BudgetExternalDonationToHighAlertMessage".localized,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in }))
        
        self.present(alert, animated: true, completion:  {})
    }
    @IBAction func amountEditingEnd(_ sender: Any) {
        checkFields()
        
        guard let amount = textFieldExternalGivtsAmount.text!.toDouble else { return }
        
        if amount > 99999 {
            alertToHighAmount()
        }
    }
    @IBAction func descriptionEditingEnd(_ sender: Any) {
        checkFields()
        
        let description = textFieldExternalGivtsOrganisation.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if description.count > 30 {
            alertToLongName()
        }
    }
    @IBAction func controlPanelButton(_ sender: Any) {
        if !AppServices.shared.isServerReachable {
            try? Mediater.shared.send(request: NoInternetAlert(), withContext: self)
            return
        }
        
        SVProgressHUD.show()

        if !isEditMode {
            let command = CreateExternalDonationCommand(
                description: textFieldExternalGivtsOrganisation.text!,
                amount: Double(textFieldExternalGivtsAmount.text!.replacingOccurrences(of: ",", with: "."))!,
                frequency: ExternalDonationFrequency(rawValue: frequencyPicker.selectedRow(inComponent: 0))!,
                date: Date()
            )
            
            NavigationManager.shared.executeWithLogin(context: self) {
                let _: ResponseModel<Bool> = try! Mediater.shared.send(request: command)
                self.resetFields()
                self.reloadExternalDonationList()
                self.enableTime()
                self.checkFields()
                self.somethingHappened = true
            }
        } else {
            switchButtonState()
            
            if let objectId = currentObjectInEditMode {
                if let model = externalDonations?.filter({$0.id == objectId}).first! {
                    if model.cronExpression == String.empty {
                        let deleteCommand = DeleteExternalDonationCommand(guid: model.id)
                        let createCommand = CreateExternalDonationCommand(
                            description: textFieldExternalGivtsOrganisation.text!,
                            amount: Double(textFieldExternalGivtsAmount.text!.replacingOccurrences(of: ",", with: "."))!,
                            frequency: ExternalDonationFrequency(rawValue: frequencyPicker.selectedRow(inComponent: 0))!,
                            date: model.creationDate.toDate!
                        )
                        NavigationManager.shared.executeWithLogin(context: self) {
                            let _: ResponseModel<Bool> = try! Mediater.shared.send(request: deleteCommand)
                            let _: ResponseModel<Bool> = try! Mediater.shared.send(request: createCommand)
                            self.resetFields()
                            self.reloadExternalDonationList()
                            self.checkFields()
                            self.somethingHappened = true
                        }
                    } else {
                        let command: UpdateExternalDonationCommand = UpdateExternalDonationCommand(
                            id: model.id,
                            amount: Double(textFieldExternalGivtsAmount.text!.replacingOccurrences(of: ",", with: "."))!,
                            cronExpression: model.cronExpression,
                            description: textFieldExternalGivtsOrganisation.text!
                        )
                        
                        NavigationManager.shared.executeWithLogin(context: self) {
                            let _: ResponseModel<Bool> = try! Mediater.shared.send(request: command)
                            self.somethingHappened = true
                        }
                    }
                }
            }
        }
        
        if somethingHappened {
            resetFields()
            reloadExternalDonationList()
            checkFields()
            buttonExternalGivtsAdd.isEnabled = false
            buttonExternalGivtsSave.isEnabled = true
            resetBorder(textField: textFieldExternalGivtsOrganisation)
            resetBorder(view: viewExternalGivtsAmount)
            buttonExternalGivtsAdd.isEnabled = false
            enableTime()
            modelBeeingEdited = nil
        }
        
        SVProgressHUD.dismiss()
    }
}
