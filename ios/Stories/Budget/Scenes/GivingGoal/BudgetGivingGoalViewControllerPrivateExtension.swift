//
//  BudgetGivingGoalViewControllerPrivateExtension.swift
//  ios
//
//  Created by Mike Pattyn on 04/05/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation

private extension BudgetGivingGoalViewController {
    @IBAction func backButton(_ sender: Any) {
        try? Mediater.shared.send(request: GoBackOneControllerRoute(), withContext: self)
    }
    
    @IBAction func buttonSave(_ sender: Any) {
        guard let amount = amountViewTextField.text?.replacingOccurrences(of: ",", with: ".").doubleValue else { return }
        guard let frequency = GivingGoalFrequency(rawValue: frequencyPicker.selectedRow(inComponent: 0)) else { return }
        
        let command = CreateGivingGoalCommand(givingGoal: GivingGoal(amount: amount, periodicity: frequency.rawValue))
        let response: ResponseModel<Bool> = try! Mediater.shared.send(request: command)
        
        if response.result {
            try? Mediater.shared.send(request: GoBackOneControllerRoute())
        }
    }
    
    @IBAction func amountEditingEnded(_ sender: Any) {
        checkFields()
    }
}
