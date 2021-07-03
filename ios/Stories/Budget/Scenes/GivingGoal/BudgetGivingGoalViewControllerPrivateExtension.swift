//
//  BudgetGivingGoalViewControllerPrivateExtension.swift
//  ios
//
//  Created by Mike Pattyn on 04/05/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import SVProgressHUD

private extension BudgetGivingGoalViewController {
    @IBAction func backButton(_ sender: Any) {
        try? Mediater.shared.send(request: GoBackFromGivingGoalWithReloadRoute(needsReload: false), withContext: self)
    }
    
    @IBAction func buttonSave(_ sender: Any) {
        trackEvent("CLICKED", properties: ["BUTTON_NAME": "SaveGivingGoal"])

        guard let amount = amountViewTextField.text?.replacingOccurrences(of: ",", with: ".").doubleValue else { return }
        guard let frequency = GivingGoalFrequency(rawValue: frequencyPicker.selectedRow(inComponent: 0)) else { return }


        let command = CreateGivingGoalCommand(givingGoal: GivingGoal(amount: amount, periodicity: frequency.rawValue))
        
        if !AppServices.shared.isServerReachable {
            try? Mediater.shared.send(request: NoInternetAlert(), withContext: self)
        } else {
            SVProgressHUD.show()
            
            NavigationManager.shared.executeWithLogin(context: self) {
                try! Mediater.shared.sendAsync(request: command, completion: { response in
                    DispatchQueue.main.async {
                        if (response as ResponseModel<Bool>).result {
                            try! Mediater.shared.send(request: GoBackFromGivingGoalWithReloadRoute(needsReload: true), withContext: self)
                        } else {
                            SVProgressHUD.dismiss()
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func amountEditingEnded(_ sender: Any) {
        checkFields()
    }
    
    @IBAction func timeTapped(_ sender: Any) {
        periodViewTextField.becomeFirstResponder()
    }
}
