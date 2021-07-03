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
enum GivingGoalFrequency: Int, Codable {
    case Monthly = 0
    case Yearly = 1
}
class BudgetGivingGoalViewController: BaseTrackingViewController {
    override var screenName: String { return "GivingGoal" }
    
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
    
    @IBOutlet weak var labelRemove: UILabel!
    
    var frequencyPicker: UIPickerView!
    
    let frequencys: Array<Array<Any>> =
        [
            [GivingGoalFrequency.Monthly, "BudgetExternalGiftsFrequencyMonthly".localized],
            [GivingGoalFrequency.Yearly, "BudgetExternalGiftsFrequencyYearly".localized]
        ]
    
    var givingGoal: GivingGoal? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: self.view.window)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        givingGoal = try! Mediater.shared.send(request: GetGivingGoalQuery()).result

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !SVProgressHUD.isVisible() {
            SVProgressHUD.show()
        }
        setupTerms()
        setupUI()
        
        if givingGoal != nil {
            labelRemove.superview!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.deleteGivingGoal)))
            labelRemove.isHidden = false
        } else {
            labelRemove.isHidden = true
        }
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }

}
