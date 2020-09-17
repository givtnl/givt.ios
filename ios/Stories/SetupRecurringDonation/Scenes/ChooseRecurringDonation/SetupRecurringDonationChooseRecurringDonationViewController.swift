//
//  ChooseRecurringDonationViewController.swift
//  ios
//
//  Created by Mike Pattyn on 27/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import SVProgressHUD
import AppCenterAnalytics
import Mixpanel

class SetupRecurringDonationChooseRecurringDonationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    private var mediater: MediaterWithContextProtocol = Mediater.shared
    
    @IBOutlet var navBar: UINavigationItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var Label1: UILabel!
    @IBOutlet weak var Label2: UILabel!
    @IBOutlet weak var Label3: UILabel!
    @IBOutlet weak var Label4: UILabel!
    @IBOutlet weak var LabelStarting: UILabel!
    
    @IBOutlet weak var amountView: AmountTextField! { didSet { amountView.amountLabel.delegate = self } }
    @IBOutlet weak var collectGroupLabel: CollectGroupLabel!
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var frequencyLabel: CustomUITextField!
    @IBOutlet weak var frequencyButton: UIButton!
    
    @IBOutlet weak var startDateLabel: CustomUITextField!
    @IBOutlet weak var startDateButton: UIButton!
    
    @IBOutlet weak var occurrencesTextField: CustomUITextField!
    @IBOutlet weak var occurrencesLabel: UILabel!
    
    @IBOutlet weak var bottomScrollViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var createSubcriptionButton: CustomButton!
    
    var input: DestinationSelectedRoute? = nil
    
    private var frequencyPicker: UIPickerView!
    private var startDatePicker: UIDatePicker!
    
    private let frequencys: Array<Array<Any>> =
        [[Frequency.Weekly, "SetupRecurringGiftWeek".localized]
            , [Frequency.Monthly, "SetupRecurringGiftMonth".localized]
            , [Frequency.ThreeMonthly, "SetupRecurringGiftQuarter".localized]
            , [Frequency.SixMonthly, "SetupRecurringGiftHalfYear".localized]
            , [Frequency.Yearly, "SetupRecurringGiftYear".localized]]
    
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
        LabelStarting.text = "SetupRecurringGiftText_4".localized
        Label4.text = "SetupRecurringGiftText_5".localized
        occurrencesLabel.text = "SetupRecurringGiftText_6".localized
        
        
        setupAmountView()
        setupOccurrencesView()
        setupFrequencyPickerView()
        setupStartDatePickerView()
        
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
        startDatePicker.date = Date()
    }
    @IBAction func openFrequencyPicker(_ sender: Any) {
        frequencyLabel.becomeFirstResponder()
        frequencyPicker.selectRow(0, inComponent: 0, animated: false)
    }
    @IBAction func backButton(_ sender: Any) {
        try? mediater.send(request: BackToRecurringDonationOverviewRoute(), withContext: self)
        MSAnalytics.trackEvent("RECURRING_DONATIONS_CREATION_DISMISSED")
        Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_CREATION_DISMISSED")
    }
    @IBAction func makeRecurringDonation(_ sender: Any) {
        self.view.endEditing(true)
        MSAnalytics.trackEvent("RECURRING_DONATIONS_CREATION_GIVE_CLICKED")
        Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_CREATION_GIVE_CLICKED")
        
        
        let cronExpression: String
        
        let dayOfMonth = startDatePicker.date.getDay()
        let month = startDatePicker.date.getMonth()
        
        switch frequencys[frequencyPicker.selectedRow(inComponent: 0)][0] as! Frequency {
        case Frequency.Weekly:
            let dayOfWeek: String
            let myCalendar = Calendar(identifier: .gregorian)
            switch myCalendar.component(.weekday, from: startDatePicker.date) {
            case 0, 7:
                dayOfWeek = "SAT"
            case 1:
                dayOfWeek = "SUN"
            case 2:
                dayOfWeek = "MON"
            case 3:
                dayOfWeek = "TUE"
            case 4:
                dayOfWeek = "WED"
            case 5:
                dayOfWeek = "THU"
            case 6:
                dayOfWeek = "FRI"
            default:
                dayOfWeek = "SUN"
            }
            cronExpression = "0 0 * * \(dayOfWeek)"
        case Frequency.Monthly:
            cronExpression = "0 0 \(dayOfMonth) * *"
        case Frequency.ThreeMonthly:
            cronExpression = "0 0 \(dayOfMonth) \(getFirstPartQuarterlyCronMonth(month: month))/3 *"
        case Frequency.SixMonthly:
            cronExpression = "0 0 \(dayOfMonth) \(getFirstPartHalfYearlyCronMonth(month: month))/6 *"
        case Frequency.Yearly:
            cronExpression = "0 0 \(dayOfMonth) \(month+1)/12 *"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDeet: String = dateFormatter.string(from: startDatePicker.date)
        
        if AppServices.shared.isServerReachable {
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
            
            let command = CreateRecurringDonationCommand(amountPerTurn: self.amountView.amount, namespace: mediumIdString, endsAfterTurns: occurencesInteger, cronExpression: cronExpression, startDate: startDeet, country: countryString)
            
            NavigationManager.shared.executeWithLogin(context: self) {
                if !LoginManager.shared.isUserLoggedIn {
                    SVProgressHUD.dismiss()
                    self.showSetupRecurringDonationFailed()
                } else {
                    do {
                        try self.mediater.sendAsync(request: command) { recurringDonationMade in
                            if(recurringDonationMade) {
                                DispatchQueue.main.async {
                                    try? self.mediater.send(request: PopToRecurringDonationOverviewRoute(), withContext: self)
                                }
                            } else {
                                SVProgressHUD.dismiss()
                                DispatchQueue.main.async {
                                    let alert = UIAlertController(title: "SomethingWentWrong".localized, message: "SetupRecurringDonationFailed".localized, preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    }))
                                    self.present(alert, animated: true, completion:  {})
                                }
                            }
                        }
                    } catch {
                        self.showSetupRecurringDonationFailed()
                    }
                }
            }
        } else {
            try? mediater.send(request: NoInternetAlert(), withContext: self)
        }
    }
    
    private func getFirstPartQuarterlyCronMonth(month: Int) -> Int {
        switch month {
        case 0,3,6,9:
            return 1
        case 1,4,7,10:
            return 2
        case 2,5,8,11:
            return 3
        default:
            return 0
        }
    }
    
    private func getFirstPartHalfYearlyCronMonth(month: Int) -> Int {
        switch month {
        case 0,1,2,3,4,5:
            return month
        case 6,7,8,9,10,11:
            return month - 6
        default:
            return 0
        }
    }
}

extension SetupRecurringDonationChooseRecurringDonationViewController : CollectGroupLabelDelegate {
    private func showSetupRecurringDonationFailed() {
        SVProgressHUD.dismiss()

        DispatchQueue.main.async {
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
        if #available(iOS 14.0, *) {
            frequencyPicker.tintColor = ColorHelper.GivtPurple
        }
        frequencyPicker.setValue(ColorHelper.GivtPurple, forKeyPath: "textColor")
        frequencyLabel.inputView = frequencyPicker
        frequencyLabel.text = frequencys[0][1] as? String
        createToolbar(frequencyLabel)
    }
    func setupStartDatePickerView() {
        startDatePicker = UIDatePicker()
        startDatePicker.datePickerMode = .date
        startDatePicker.addTarget(self, action: #selector(handleStartDatePicker), for: .valueChanged)
        if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
            startDatePicker.minimumDate = newDate
        }
        if #available(iOS 14.0, *) {
            startDatePicker.preferredDatePickerStyle = .wheels
            startDatePicker.tintColor = ColorHelper.GivtPurple
        } else {
            startDatePicker.setValue(false, forKeyPath: "highlightsToday")
        }
        startDatePicker.setValue(ColorHelper.GivtPurple, forKeyPath: "textColor")
        
        startDateLabel.text = startDatePicker.date.formatted
        startDateLabel.inputView = startDatePicker
        createToolbar(startDateLabel)
    }
    
    func collectGroupLabelTapped() {
        MSAnalytics.trackEvent("RECURRING_DONATIONS_CREATION_SELECT_RECIPIENT")
        Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_CREATION_SELECT_RECIPIENT")
        hideKeyboard()
        try? mediater.send(request: SetupRecurringDonationChooseDestinationRoute(mediumId: ""), withContext: self)
    }
    
    private func ensureButtonHasCorrectState() {
        let amount = amountView.amount
        let endsAfterTurns = Int(occurrencesTextField.text!) ?? 0
        createSubcriptionButton.isEnabled = amount >= 0.5
            && amount <= 99999
            && endsAfterTurns >= 1
            && endsAfterTurns <= 999
            && input?.mediumId != nil
        
    }
    
    private func setupAmountView() {
        // get the currency symbol from user settingsf
        amountView.currency = UserDefaults.standard.currencySymbol
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
        createToolbar(occurrencesTextField)
        occurrencesTextField.keyboardType = .numberPad
        // setup event handlers
        occurrencesTextField.addTarget(self, action: #selector(handleOccurrencesEditingChanged), for: .editingChanged)
        occurrencesTextField.addTarget(self, action: #selector(handleOccurrencesEditingEnd), for: .editingDidEnd)
    }
    
    private func setupCollectGroupLabel() {
        collectGroupLabel.delegate = self
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
                    text = "hands-helping";
                case CollectGroupType.church:
                    text = "place-of-worship";
                case CollectGroupType.debug:
                    text = "debug";
                case CollectGroupType.demo:
                    text = "democrat";
                default:
                    text = "hands-helping";
                }
                collectGroupLabel.symbol.text = text
                collectGroupLabel.symbolView.isHidden = false;
            }
        }
    }
    
    @objc func handleStartDatePicker(_ datePicker: UIDatePicker) {
        startDateLabel.text = datePicker.date.formatted
        MSAnalytics.trackEvent("RECURRING_DONATIONS_CREATION_STARTDATE_CHANGED")
        Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_CREATION_STARTDATE_CHANGED")
        
    }
    
    @objc func handleAmountEditingChanged() {
        if(amountView.amount >= 0.5 && amountView.amount <= 99999) {
            amountView.bottomBorderColor = ColorHelper.GivtGreen
        } else {
            amountView.bottomBorderColor = ColorHelper.GivtRed
        }
    }
    
    @objc func handleAmountEditingDidBegin() {
        if(amountView.amount == 0) {
            amountView.bottomBorderColor = .clear
        }
    }
    @objc func handleAmountEditingDidEnd() {
        MSAnalytics.trackEvent("RECURRING_DONATIONS_CREATION_AMOUNT_ENTERED")
        Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_CREATION_AMOUNT_ENTERED")
        
        if(amountView.amount < 0.5) {
            showAmountTooLow()
        } else if (amountView.amount > 99999) {
            displayAmountTooHigh()
        }
        ensureButtonHasCorrectState()
    }
    
    @objc func handleOccurrencesEditingChanged() {
        if let times = Int(occurrencesTextField.text!) {
            if(times == 0) {
                occurrencesTextField.setBorderColor(.red)
            } else {
                occurrencesTextField.resetBorderColor()
            }
        }
        ensureButtonHasCorrectState()
    }
    @objc func handleOccurrencesEditingEnd() {
        MSAnalytics.trackEvent("RECURRING_DONATIONS_CREATION_TIMES_ENTERED")
        Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_CREATION_TIMES_ENTERED")
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
        self.frequencyLabel.text = frequencys[row][1] as? String
        MSAnalytics.trackEvent("RECURRING_DONATIONS_CREATION_FREQUENCY_CHANGED", withProperties:["frequency": frequencys[row][1] as! String])
        Mixpanel.mainInstance().track(event: "RECURRING_DONATIONS_CREATION_FREQUENCY_CHANGED", properties: ["frequency": frequencys[row][1] as! String])
        pickerView.reloadAllComponents()
        ensureButtonHasCorrectState()
    }
    
    private enum Frequency {
        case Weekly
        case Monthly
        case ThreeMonthly
        case SixMonthly
        case Yearly
    }
    
    func createToolbar(_ textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(hideKeyboard))
        
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        textField.inputAccessoryView = toolbar
    }
    fileprivate func displayAmountTooHigh() {
        let alert = UIAlertController(
            title: "AmountTooHigh".localized,
            message: "AmountLimitExceeded".localized,
            preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "ChooseLowerAmount".localized, style: .default) { action in })
        self.present(alert, animated: true, completion: nil)
    }
    fileprivate func showAmountTooLow() {
        let minimumAmount = UserDefaults.standard.currencySymbol == "£" ? "GivtMinimumAmountPond".localized : "GivtMinimumAmountEuro".localized
        let alert = UIAlertController(title: "AmountTooLow".localized,
                                      message: "GivtNotEnough".localized.replacingOccurrences(of: "{0}", with: minimumAmount.replacingOccurrences(of: ".", with: decimalNotation)), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in  }))
        self.present(alert, animated: true, completion: {})
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
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
