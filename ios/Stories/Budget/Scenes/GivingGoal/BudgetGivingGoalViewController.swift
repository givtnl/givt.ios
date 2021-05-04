//
//  BudgetGivingGoalViewController.swift
//  ios
//
//  Created by Mike Pattyn on 04/05/2021.
//  Copyright © 2021 Givt. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
enum GivingGoalFrequency {
    case Monthly
    case Yearly
}
class BudgetGivingGoalViewController: UIViewController {
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var buttonSave: CustomButton!
    
    @IBOutlet weak var amountTitelLabel: UILabel!
    @IBOutlet weak var amountView: BudgetExternalGivtsViewWithBorder!
    @IBOutlet weak var amountViewLabelCurrency: UILabel!
    @IBOutlet weak var amountViewTextField: TextFieldWithInset!
    
    @IBOutlet weak var periodTitelLabel: UILabel!
    @IBOutlet weak var periodView: CustomButton!
    @IBOutlet weak var periodViewLabelDown: UILabel!
    @IBOutlet weak var periodViewTextField: TextFieldWithInset!
    
    @IBOutlet weak var bottomScrollViewConstraint: NSLayoutConstraint!
    
    var frequencyPicker: UIPickerView!
    
    let frequencys: Array<Array<Any>> =
        [
            [GivingGoalFrequency.Monthly, "BudgetExternalGiftsFrequencyMonthly".localized],
            [GivingGoalFrequency.Yearly, "BudgetExternalGiftsFrequencyYearly".localized]
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: self.view.window)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !SVProgressHUD.isVisible() {
            SVProgressHUD.show()
        }
        setupTerms()
        setupUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }

}
