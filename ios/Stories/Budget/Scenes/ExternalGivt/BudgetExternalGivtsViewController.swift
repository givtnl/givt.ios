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
import CoreData

class BudgetExternalGivtsViewController : UIViewController {
    @IBOutlet weak var labelExternalGivtsInfo: UILabel!
    @IBOutlet weak var labelExternalGivtsSubtitle: UILabel!
    @IBOutlet weak var labelExternalGivtsOrganisation: UILabel!
    @IBOutlet weak var textFieldExternalGivtsOrganisation: TextFieldWithInset!
    @IBOutlet weak var labelExternalGivtsTime: UILabel!
    @IBOutlet weak var labelExternalGivtsTimeDown: TextFieldWithInset!
    @IBOutlet weak var textFieldExternalGivtsTime: TextFieldWithInset!
    @IBOutlet weak var labelChevronDown: UILabel!
    @IBOutlet weak var labelExternalGivtsAmount: UILabel!
    @IBOutlet weak var labelExternalGivtsAmountCurrency: UILabel!
    @IBOutlet weak var labelTaxDeductable: UILabel!
    @IBOutlet weak var textFieldExternalGivtsAmount: UITextField!
    @IBOutlet weak var buttonExternalGivtsAdd: CustomButton!
    @IBOutlet weak var buttonExternalGivtsSave: CustomButton!
    @IBOutlet weak var switchTaxDeductable: UISwitch!
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    @IBOutlet weak var viewExternalGivtsTime: CustomButton!
    @IBOutlet weak var viewExternalGivtsAmount: BudgetExternalGivtsViewWithBorder!
    
    @IBOutlet weak var bottomScrollViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var stackViewEditRows: UIStackView!
    @IBOutlet weak var stackViewEditRowsHeight: NSLayoutConstraint!
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    var frequencyPicker: UIPickerView!
    let frequencys: Array<Array<Any>> =
        [
            [ExternalDonationFrequency.Once, "BudgetExternalGiftsFrequencyOnce".localized],
            [ExternalDonationFrequency.Monthly, "BudgetExternalGiftsFrequencyMonthly".localized],
            [ExternalDonationFrequency.Quarterly, "BudgetExternalGiftsFrequencyQuarterly".localized],
            [ExternalDonationFrequency.HalfYearly, "BudgetExternalGiftsFrequencyHalfYearly".localized],
            [ExternalDonationFrequency.Yearly, "BudgetExternalGiftsFrequencyYearly".localized]
        ]
    
    var externalDonations: [ExternalDonationModel]? = nil
    
    var isEditMode: Bool = false
    var currentObjectInEditMode: String? = nil
    var originalStackviewHeightConstant: CGFloat? = nil
    var modelBeeingEdited: ExternalDonationModel? = nil
    var somethingHappened = false
    
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
        loadDonations()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.dismiss()
        if (modelBeeingEdited != nil) {
            mainScrollView.scrollToBottom()
        }
    }

}
