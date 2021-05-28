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
            try? Mediater.shared.send(request: GoBackOneControllerRoute(), withContext: self)
        }
    }
    
    @IBAction func buttonSave(_ sender: Any) {
        if !AppServices.shared.isServerReachable {
            try? Mediater.shared.send(request: NoInternetAlert(), withContext: self)
        } else {
            try? Mediater.shared.send(request: GoBackOneControllerRoute(), withContext: self)
        }
    }

    @IBAction func timeTapped(_ sender: Any) {
        textFieldExternalGivtsTime.becomeFirstResponder()
    }
    
    @IBAction func amountEditingEnd(_ sender: Any) {
        checkFields()
    }
    @IBAction func descriptionEditingEnd(_ sender: Any) {
        checkFields()
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
