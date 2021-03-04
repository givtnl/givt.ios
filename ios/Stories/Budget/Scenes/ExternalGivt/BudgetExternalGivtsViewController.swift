//
//  ExternalGivtController.swift
//  ios
//
//  Created by Mike Pattyn on 27/02/2021.
//  Copyright © 2021 Givt. All rights reserved.
//
import UIKit
import Foundation
import SVProgressHUD

class BudgetExternalGivtsViewController : UIViewController {
    @IBOutlet weak var labelExternalGivtsInfo: UILabel!
    @IBOutlet weak var labelExternalGivtsSubtitle: UILabel!
    @IBOutlet weak var labelExternalGivtsOrganisation: UILabel!
    @IBOutlet weak var textFieldExternalGivtsOrganisation: TextFieldWithInset!
    @IBOutlet weak var labelExternalGivtsTime: UILabel!
    @IBOutlet weak var labelExternalGivtsTimeDown: TextFieldWithInset!
    @IBOutlet weak var textFieldExternalGivtsTime: TextFieldWithInset!
    @IBOutlet weak var labelExternalGivtsAmount: UILabel!
    @IBOutlet weak var labelExternalGivtsAmountCurrency: UILabel!
    @IBOutlet weak var textFieldExternalGivtsAmount: UITextField!
    @IBOutlet weak var buttonExternalGivtsAdd: CustomButton!
    @IBOutlet weak var buttonExternalGivtsSave: CustomButton!

    @IBOutlet weak var viewExternalGivtsTime: CustomButton!
    @IBOutlet weak var viewExternalGivtsAmount: BudgetExternalGivtsViewWithBorder!
    
    @IBOutlet weak var bottomScrollViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var stackViewEditRows: UIStackView!
    @IBOutlet weak var stackViewEditRowsHeight: NSLayoutConstraint!
    
    var frequencyPicker: UIPickerView!
    var selectedFrequencyIndex: Int? = nil
    let frequencys: Array<Array<Any>> =
        [[Frequency.Weekly, "SetupRecurringGiftWeek".localized]
            , [Frequency.Monthly, "SetupRecurringGiftMonth".localized]
            , [Frequency.ThreeMonthly, "SetupRecurringGiftQuarter".localized]
            , [Frequency.SixMonthly, "SetupRecurringGiftHalfYear".localized]
            , [Frequency.Yearly, "SetupRecurringGiftYear".localized]]
    
    var externalGivtsModels: [NotGivtDonationModel]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: self.view.window)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        setupTerms()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        if !SVProgressHUD.isVisible() {
            SVProgressHUD.show()
        }
        
        externalGivtsModels = try! Mediater.shared.send(request: GetNotGivtDonationsQuery())
        
        externalGivtsModels!.forEach { model in
            let newRow = BudgetExternalGivtsEditRow(guid: model.GUID, name: model.Name, amount: model.Amount)
            newRow.editButton.addTarget(self, action: #selector(editButtonRow), for: .touchUpInside)
            stackViewEditRows.addArrangedSubview(newRow)
        }
        
        stackViewEditRowsHeight.constant += CGFloat(externalGivtsModels!.count) * 44
        stackViewEditRowsHeight.constant += CGFloat(externalGivtsModels!.count - 1) * 10
    }
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    @objc func editButtonRow(_ sender: UIButton) {
        let editRowGuid = getEditRowFrom(button: sender).guid!
        let model = externalGivtsModels!.filter{$0.GUID == editRowGuid}.first!
        textFieldExternalGivtsOrganisation.text = model.Name
        textFieldExternalGivtsAmount.text = model.Amount.getFormattedWithoutCurrency(decimals: 2)
        
    }
    private func getEditRowFrom(button: UIButton) -> BudgetExternalGivtsEditRow {
        return button.superview?.superview?.superview?.superview as! BudgetExternalGivtsEditRow
    }
}
