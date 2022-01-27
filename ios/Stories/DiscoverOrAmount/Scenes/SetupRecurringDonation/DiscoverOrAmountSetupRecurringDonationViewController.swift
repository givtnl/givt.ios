//
//  DiscoverOrAmountSetupRecurringDonationViewController.swift
//  ios
//
//  Created by Mike Pattyn on 29/10/2020.
//  Copyright © 2020 Givt. All rights reserved.
//


import UIKit
import SVProgressHUD
import AppCenterAnalytics
import Mixpanel

class DiscoverOrAmountSetupRecurringDonationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    private var mediater: MediaterWithContextProtocol = Mediater.shared
    
    @IBOutlet var navBar: UINavigationItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var Label1: UILabel!
    @IBOutlet weak var Label2: UILabel!
    @IBOutlet weak var Label3: UILabel!
    @IBOutlet weak var Label4: UILabel!
    @IBOutlet weak var Label5: UILabel!
    @IBOutlet weak var Label6: UILabel!
    
    @IBOutlet weak var amountView: AmountTextField! { didSet { amountView.amountLabel.delegate = self } }
    @IBOutlet weak var collectGroupLabel: CollectGroupLabel!
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var frequencyLabel: RecurringCustomUITextField!
    @IBOutlet weak var frequencyButton: UIButton!
    
    @IBOutlet weak var startDateLabel: RecurringCustomUITextField!
    @IBOutlet weak var startDateButton: UIButton!
    
    @IBOutlet weak var endDateLabel: RecurringCustomUITextField!
    @IBOutlet weak var endDateButton: UIButton!
    
    @IBOutlet weak var occurrencesTextField: RecurringCustomUITextField!
    
    @IBOutlet weak var bottomScrollViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var createSubcriptionButton: CustomButton!
    
    var input: DiscoverOrAmountOpenSetupRecurringDonationRoute? = nil
    
    private var frequencyPicker: UIPickerView!
    private var startDatePicker: UIDatePicker!
    private var endDatePicker: UIDatePicker!
    
    private let frequencys: Array<Array<Any>> =
        [[Frequency.Weekly, "SetupRecurringGiftWeek".localized]
         , [Frequency.Monthly, "SetupRecurringGiftMonth".localized]
         , [Frequency.ThreeMonthly, "SetupRecurringGiftQuarter".localized]
         , [Frequency.SixMonthly, "SetupRecurringGiftHalfYear".localized]
         , [Frequency.Yearly, "SetupRecurringGiftYear".localized]]
    
    private var selectedFrequencyIndex: Int? = nil
    
    private let animationDuration = 0.4
    private var decimalNotation: String! = "," {
        didSet {
            let fmt = NumberFormatter()
            fmt.minimumFractionDigits = 2
            fmt.minimumIntegerDigits = 1
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: self.view.window)
        
        Label1.text = "SetupRecurringGiftText_1".localized
        Label2.text = "SetupRecurringGiftText_2".localized
        Label3.text = "SetupRecurringGiftText_3".localized
        Label4.text = "SetupRecurringGiftText_4".localized
        Label5.text = "SetupRecurringGiftText_5".localized
        Label6.text = "SetupRecurringGiftText_6".localized
        
        setupAmountView()
        setupOccurrencesView()
        setupFrequencyPickerView()
        setupStartDatePickerView()
        setupEndDatePickerView()
        
        createSubcriptionButton.accessibilityLabel = "Give".localized
        createSubcriptionButton.setTitle("Give".localized, for: .normal)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "SetupRecurringGiftTitle".localized
        navigationItem.accessibilityLabel = "SetupRecurringGiftTitle".localized
        setupCollectGroupLabel()
        ensureButtonHasCorrectState()
    }
    
    @IBAction func openStartDatePicker(_ sender: Any) {
        startDateLabel.becomeFirstResponder()
    }
    
    @IBAction func openEndDatePicker(_ sender: Any) {
        endDateLabel.becomeFirstResponder()
        if endDateLabel.text! == "" {
            endDatePicker.setDate(Date.tomorrow, animated: true)
        }
    }
    
    @IBAction func openFrequencyPicker(_ sender: Any) {
        frequencyLabel.becomeFirstResponder()
        let selectedIndex: Int = selectedFrequencyIndex ?? 0
        frequencyPicker.selectRow(selectedIndex, inComponent: 0, animated: false)
    }
    
    @IBAction func backButton(_ sender: Any) {
        try? mediater.send(request: GoBackOneControllerRoute(), withContext: self)
        Analytics.trackEvent("RECURRING_DONATIONS_CREATION_DISMISSED")
        Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_CREATION_DISMISSED")
    }
    
    @IBAction func makeRecurringDonation(_ sender: Any) {
        self.view.endEditing(true)
        
        if amountView.amount > UserDefaults.standard.amountLimit.decimal {
            displayAmountHigherThenAmountLimit()
        } else {
            makeDonation()
        }
        
        Analytics.trackEvent("RECURRING_DONATIONS_CREATION_GIVE_CLICKED")
        Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_CREATION_GIVE_CLICKED")
    }
}

extension DiscoverOrAmountSetupRecurringDonationViewController {
    private func makeDonation() {
        if !AppServices.shared.isServerReachable {
            try? mediater.send(request: NoInternetAlert(), withContext: self)
            return
        }
        
        SVProgressHUD.show()
        
        guard let countryString: String = try? mediater.send(request: GetCountryQuery()) else {
            self.showSetupRecurringDonationFailed()
            return
        }
        
        guard let mediumIdString: String = self.input?.mediumId else {
            self.showSetupRecurringDonationFailed()
            return
        }
        
        guard let occurencesInteger: Int = Int(self.occurrencesTextField.text!) else {
            self.showSetupRecurringDonationFailed()
            return
        }
        
        let command = CreateRecurringDonationCommand(amountPerTurn: self.amountView.amount, namespace: mediumIdString, endsAfterTurns: occurencesInteger, startDate: startDatePicker.date.toString("yyyy-MM-dd"), country: countryString, frequency: frequencys[frequencyPicker.selectedRow(inComponent: 0)][0] as! Frequency)
        
        NavigationManager.shared.executeWithLogin(context: self) {
            if !LoginManager.shared.isUserLoggedIn {
                self.showSetupRecurringDonationFailed()
            } else {
                do {
                    try self.mediater.sendAsync(request: command) { recurringDonationMade in
                        if !recurringDonationMade.result {
                            if recurringDonationMade.error == .duplicate {
                                DispatchQueue.main.async {
                                    SVProgressHUD.dismiss()
                                    let alert = UIAlertController(title: "SetupRecurringDonationFailedDuplicateTitle".localized, message: "SetupRecurringDonationFailedDuplicate".localized, preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in }))
                                    self.present(alert, animated: true, completion:  {})
                                }
                            } else {
                                self.showSetupRecurringDonationFailed()
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            try? self.mediater.send(request: DiscoverOrAmountOpenRecurringSuccessRoute(collectGroupName: self.collectGroupLabel.label.text!), withContext: self)
                        }
                    }
                } catch {
                    self.showSetupRecurringDonationFailed()
                }
            }
        }
        
    }
    private func showSetupRecurringDonationFailed() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            let alert = UIAlertController(title: "SomethingWentWrong".localized, message: "SetupRecurringDonationFailed".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            }))
            self.present(alert, animated: true, completion:  {})
        }
    }
    
    func setupFrequencyPickerView() {
        frequencyPicker = UIPickerView()
        frequencyPicker.dataSource = self
        frequencyPicker.delegate = self
        frequencyPicker.selectRow(0, inComponent: 0, animated: false)
        frequencyPicker.setValue(ColorHelper.GivtPurple, forKeyPath: "textColor")
        frequencyPicker.tintColor = ColorHelper.GivtPurple
        frequencyLabel.inputView = frequencyPicker
        frequencyLabel.text = frequencys[0][1] as? String
        createToolbar(frequencyLabel)
    }
    
    func setupStartDatePickerView() {
        startDatePicker = UIDatePicker()
        startDatePicker.setDate(Date.tomorrow, animated: true)
        startDatePicker.datePickerMode = .date
        startDatePicker.addTarget(self, action: #selector(handleStartDatePicker), for: .valueChanged)
                
        startDatePicker.tintColor = ColorHelper.GivtPurple
        startDatePicker.setValue(ColorHelper.GivtPurple, forKeyPath: "textColor")

        if #available(iOS 13.4, *) {
            startDatePicker.preferredDatePickerStyle = .wheels
        }
        
        startDateLabel.text = startDatePicker.date.formattedShort
        startDateLabel.inputView = startDatePicker
        createToolbar(startDateLabel)
    }
    
    func setupEndDatePickerView() {
        endDatePicker = UIDatePicker()
        endDatePicker.datePickerMode = .date
        endDatePicker.addTarget(self, action: #selector(handleEndDatePicker), for: .valueChanged)
                
        startDatePicker.tintColor = ColorHelper.GivtPurple
        startDatePicker.setValue(ColorHelper.GivtPurple, forKeyPath: "textColor")
        
        if #available(iOS 13.4, *) {
            endDatePicker.preferredDatePickerStyle = .wheels
        }

        endDateLabel.placeholder = "dd/mm/yyyy"
        endDateLabel.text = String.empty
        endDateLabel.inputView = endDatePicker
        
        createToolbar(endDateLabel)
    }
    
    private func ensureButtonHasCorrectState() {
        let amount = amountView.amount
        let endsAfterTurns = Int(occurrencesTextField.text!) ?? 0
        
        startDateLabel.handleInputValidation(invalid: Date() > startDatePicker.date )
        endDateLabel.handleInputValidation(invalid: endDateLabel.text! != "" && endDatePicker.date.shortDate < startDatePicker.date.shortDate)
        occurrencesTextField.handleInputValidation(invalid: occurrencesTextField.text! != "" && (endsAfterTurns < 1 || endsAfterTurns > 999))
        
        createSubcriptionButton.isEnabled = startDateLabel.inputValid
            && endDateLabel.inputValid
            && occurrencesTextField.inputValid
            && amount >= GivtManager.shared.minimumAmount
            && amount <= 99999
            && endsAfterTurns >= 1
            && endsAfterTurns <= 999
            && input?.mediumId != nil
    }
    
    private func setupAmountView() {
        // get the currency symbol from user settingsf
        amountView.currency = CurrencyHelper.shared.getCurrencySymbol()
        amountView.bottomBorderColor = UIColor.clear
        
        // setup event handlers
        amountView.amountLabel.addTarget(self, action: #selector(handleAmountEditingChanged), for: .editingChanged)
        amountView.amountLabel.addTarget(self, action: #selector(handleAmountEditingDidBegin), for: .editingDidBegin)
        amountView.amountLabel.addTarget(self, action: #selector(handleAmountEditingDidEnd), for: .editingDidEnd)
        
        // setup toolbar for the keyboard
        createToolbar(amountView.amountLabel)
        
        // set number keypad
        amountView.amountLabel.keyboardType = .decimalPad
    }
    
    private func setupOccurrencesView() {
        occurrencesTextField.isOccurrencesLabel = true
        createToolbar(occurrencesTextField)
        
        occurrencesTextField.keyboardType = .numberPad
        occurrencesTextField.placeholder = "X"
        
        // setup event handlers
        occurrencesTextField.addTarget(self, action: #selector(handleOccurrencesEditingBegan), for: .editingDidBegin)
        occurrencesTextField.addTarget(self, action: #selector(handleOccurrencesEditingChanged), for: .editingChanged)
        occurrencesTextField.addTarget(self, action: #selector(handleOccurrencesEditingEnd), for: .editingDidEnd)
    }
    
    private func setupCollectGroupLabel() {
        collectGroupLabel.label.text = "SelectRecipient".localized
        collectGroupLabel.bottomBorderColor = UIColor.clear
        collectGroupLabel.symbolView.isHidden = true;
        collectGroupLabel.symbol.text = ""
        if let input = self.input {
            collectGroupLabel.label.text = input.name
            
            if (collectGroupLabel.label.text != "SelectRecipient".localized) {
                collectGroupLabel.bottomBorderColor = #colorLiteral(red: 0.1137254902, green: 0.662745098, blue: 0.4235294118, alpha: 1)
                let text: String
                switch input.orgType {
                case CollectGroupType.artist:
                    text = "guitar"
                case CollectGroupType.campaign:
                    text = "hand-holding-heart";
                case CollectGroupType.charity:
                    text = "heart";
                case CollectGroupType.church:
                    text = "place-of-worship";
                case CollectGroupType.debug:
                    text = "debug";
                case CollectGroupType.demo:
                    text = "democrat";
                default:
                    text = "heart"
                }
                collectGroupLabel.symbol.text = text
                collectGroupLabel.symbolView.isHidden = false;
            }
        }
    }
    
    func calculateTimes(until: Date) -> String {
        var times = 0
        var startDate = startDatePicker.date;
        let frequency = Frequency(rawValue: frequencyPicker.selectedRow(inComponent: 0))!
        
        while startDate.shortDate <= until.shortDate {
            switch frequency {
            case Frequency.Weekly:
                var dateComponent = DateComponents()
                dateComponent.weekday = 7
                startDate = Calendar.current.date(byAdding: dateComponent, to: startDate)!
            case Frequency.Monthly:
                var dateComponent = DateComponents()
                dateComponent.month = 1
                startDate = Calendar.current.date(byAdding: dateComponent, to: startDate)!
            case Frequency.ThreeMonthly:
                var dateComponent = DateComponents()
                dateComponent.month = 3
                startDate = Calendar.current.date(byAdding: dateComponent, to: startDate)!
            case Frequency.SixMonthly:
                var dateComponent = DateComponents()
                dateComponent.month = 6
                startDate = Calendar.current.date(byAdding: dateComponent, to: startDate)!
            case Frequency.Yearly:
                var dateComponent = DateComponents()
                dateComponent.year = 1
                startDate = Calendar.current.date(byAdding: dateComponent, to: startDate)!
            }
            times+=1
        }
        return times.string
    }
    
    func calculateEndDate(withTimes: Int) -> Date {
        var times = withTimes
        var startDate = startDatePicker.date
        let frequency = Frequency(rawValue: frequencyPicker.selectedRow(inComponent: 0))!

        while times > 1 {
            switch frequency {
            case Frequency.Weekly:
                var dateComponent = DateComponents()
                dateComponent.weekday = 7
                startDate = Calendar.current.date(byAdding: dateComponent, to: startDate)!
            case Frequency.Monthly:
                var dateComponent = DateComponents()
                dateComponent.month = 1
                startDate = Calendar.current.date(byAdding: dateComponent, to: startDate)!
            case Frequency.ThreeMonthly:
                var dateComponent = DateComponents()
                dateComponent.month = 3
                startDate = Calendar.current.date(byAdding: dateComponent, to: startDate)!
            case Frequency.SixMonthly:
                var dateComponent = DateComponents()
                dateComponent.month = 6
                startDate = Calendar.current.date(byAdding: dateComponent, to: startDate)!
            case Frequency.Yearly:
                var dateComponent = DateComponents()
                dateComponent.year = 1
                startDate = Calendar.current.date(byAdding: dateComponent, to: startDate)!
            }
            times-=1
        }
        return startDate
    }
    
    @objc func handleStartDatePicker(_ datePicker: UIDatePicker) {
        startDateLabel.text = datePicker.date.formattedShort
        
        if endDatePicker.date > startDatePicker.date {
            occurrencesTextField.text = calculateTimes(until: endDatePicker.date)
        } else {
            endDatePicker.date = startDatePicker.date
            endDateLabel.text = startDateLabel.text
            occurrencesTextField.text = 1.string
        }
        ensureButtonHasCorrectState()
    }
    
    @objc func handleEndDatePicker(_ datePicker: UIDatePicker) {
        endDateLabel.text = datePicker.date.formattedShort
        occurrencesTextField.text = calculateTimes(until: datePicker.date)
        ensureButtonHasCorrectState()
    }
    
    @objc func handleAmountEditingChanged() {
        if amountView.amount >= GivtManager.shared.minimumAmount && amountView.amount <= 99999 {
            amountView.bottomBorderColor = ColorHelper.GivtGreen
        } else {
            amountView.bottomBorderColor = ColorHelper.GivtRed
        }
        ensureButtonHasCorrectState()
    }
    
    @objc func handleAmountEditingDidBegin() {
        if amountView.amount == 0 {
            amountView.bottomBorderColor = .clear
        }
    }
    
    @objc func handleAmountEditingDidEnd() {
        if amountView.amount > 0 && amountView.amount < GivtManager.shared.minimumAmount {
            showAmountTooLow()
        } else if amountView.amount > 99999 {
            displayAmountTooHigh()
        }
        ensureButtonHasCorrectState()
    }
    
    @objc func handleOccurrencesEditingChanged() {
        if var times = Int(occurrencesTextField.text!) {
            if times <= 0 {
                occurrencesTextField.text = "1"
                times = 1
            } else if times > 999 {
                occurrencesTextField.text = "999"
                times = 999
            }
            endDatePicker.date = calculateEndDate(withTimes: times)
            handleEndDatePicker(endDatePicker)
        }
        ensureButtonHasCorrectState()
    }
    
    @objc func handleOccurrencesEditingBegan() {
        if let times = Int(occurrencesTextField.text!) {
            occurrencesTextField.text = times.string
        } else {
            occurrencesTextField.text = String.empty
        }
        ensureButtonHasCorrectState()
    }
    
    @objc func handleOccurrencesEditingEnd() {
        if occurrencesTextField.text == String.empty {
            occurrencesTextField.text = calculateTimes(until: endDatePicker.date)
        }
        ensureButtonHasCorrectState()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return frequencys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return frequencys[row][1] as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedFrequencyIndex = row
        self.frequencyLabel.text = frequencys[row][1] as? String
        pickerView.reloadAllComponents()
        
        resetDatesAndTimes()
        ensureButtonHasCorrectState()
    }
    
    func createToolbar(_ textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(toolbarDoneButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        textField.inputAccessoryView = toolbar
    }
    
    func resetDatesAndTimes() {
        endDatePicker.date = Date.tomorrow
        handleEndDatePicker(endDatePicker)
        endDateLabel.text = String.empty
        occurrencesTextField.text = String.empty
    }
    
    fileprivate func displayAmountTooHigh() {
        let alert = UIAlertController(
            title: "AmountTooHigh".localized,
            message: "AmountLimitExceeded".localized,
            preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "ChooseLowerAmount".localized, style: .default) { action in })
        self.present(alert, animated: true, completion: nil)
    }
    fileprivate func displayAmountHigherThenAmountLimit() {
        let alert = UIAlertController(
            title: nil,
            message: "AmountLimitExceededRecurringDonation".localized,
            preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "ChooseLowerAmount".localized, style: .default) { action in })
        alert.addAction(UIAlertAction(title: "Continue".localized, style: .default) { action in
            self.makeDonation()
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func showAmountTooLow() {
        let minimumAmount = { () -> String in
            switch UserDefaults.standard.paymentType {
            case .BACSDirectDebit:
                return "GivtMinimumAmountPond".localized
            case .CreditCard:
                return "GivtMinimumAmountDollar".localized
            default:
                return "GivtMinimumAmountEuro".localized
            }
        }()
        let alert = UIAlertController(title: "AmountTooLow".localized,
                                      message: "GivtNotEnough".localized.replacingOccurrences(of: "{0}", with: minimumAmount.replacingOccurrences(of: ".", with: decimalNotation)), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in  }))
        self.present(alert, animated: true, completion: {})
    }
    
    @objc func toolbarDoneButtonTapped(_ sender: UIBarButtonItem){
        self.view.endEditing(true)
        if let toolbar = startDateLabel.inputAccessoryView as? UIToolbar,
           toolbar.items?.contains(where: { item in item == sender }) == true {
            handleStartDatePicker(startDatePicker)
        } else if let toolbar = endDateLabel.inputAccessoryView as? UIToolbar,
           toolbar.items?.contains(where: { item in item == sender }) == true {
            handleEndDatePicker(endDatePicker)
        }
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        if #available(iOS 11.0, *) {
            bottomScrollViewConstraint.constant = keyboardFrame.size.height - view.safeAreaInsets.bottom
        } else {
            bottomScrollViewConstraint.constant = keyboardFrame.size.height
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
