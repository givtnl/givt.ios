//
//  ChooseSubscriptionViewController.swift
//  ios
//
//  Created by Mike Pattyn on 27/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit

class SetupRecurringDonationChooseSubscriptionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
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
    @IBOutlet weak var frequencyPicker: UIPickerView!
    
    @IBOutlet weak var startDateLabel: CustomUITextField!
    @IBOutlet weak var startDateButton: UIButton!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    
    @IBOutlet weak var occurencesTextField: CustomUITextField!
    @IBOutlet weak var occurencesLabel: UILabel!
    
    @IBOutlet weak var bottomScrollViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var createSubcriptionButton: CustomButton!
    
    var input: DestinationSelectedRoute? = nil
    
    private var pickers: Array<Any> = [Any]()
    
     private let frequencys: Array<Array<Any>> =
        [[Frequency.Weekly, NSLocalizedString("SetupRecurringGiftWeek", comment: ""), NSLocalizedString("SetupRecurringGiftText_6", comment: "")]
        , [Frequency.Monthly, NSLocalizedString("SetupRecurringGiftMonth", comment: ""), NSLocalizedString("SetupRecurringGiftText_6", comment: "")]
        , [Frequency.ThreeMonthly, NSLocalizedString("SetupRecurringGiftQuarter", comment: ""), NSLocalizedString("SetupRecurringGiftText_6", comment: "")]
        , [Frequency.SixMonthly, NSLocalizedString("SetupRecurringGiftHalfYear", comment: ""), NSLocalizedString("SetupRecurringGiftText_6", comment: "")]
        , [Frequency.Yearly, NSLocalizedString("SetupRecurringGiftYear", comment: ""), NSLocalizedString("SetupRecurringGiftText_6", comment: "")]]
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:Notification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: self.view.window)
        Label1.text = NSLocalizedString("SetupRecurringGiftText_1", comment: "")
        Label2.text = NSLocalizedString("SetupRecurringGiftText_2", comment: "")
        Label3.text = NSLocalizedString("SetupRecurringGiftText_3", comment: "")
        LabelStarting.text = NSLocalizedString("SetupRecurringGiftText_4", comment: "")
        Label4.text = NSLocalizedString("SetupRecurringGiftText_5", comment: "")
        
        setupAmountView()
        setupStartDatePicker()
        setupFrequencyPicker()
        setupOccurencsView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupCollectGroupLabel()
        ensureButtonHasCorrectState()
    }
    
    @IBAction func openStartDatePicker(_ sender: Any) {
        if (startDatePicker.isHidden) {
            closeAllOpenPickerViews()
            UIView.animate(
                withDuration: animationDuration,
                delay: 0.0,
                options: [.curveEaseOut],
                animations: {
                    self.startDatePicker.isHidden = false
                    self.startDatePicker.alpha = 1
            })
        } else {
            UIView.animate(
                withDuration: animationDuration,
                delay: 0.0,
                options: [.curveEaseOut],
                animations: {
                    self.startDatePicker.isHidden = true
                    self.startDatePicker.alpha = 0
            })
        }
    }
    
    @IBAction func openFrequencyPicker(_ sender: Any) {
        if (frequencyPicker.isHidden) {
            closeAllOpenPickerViews()
            UIView.animate(
                withDuration: animationDuration,
                delay: 0.0,
                options: [.curveEaseOut],
                animations: {
                    self.frequencyPicker.isHidden = false
                    self.frequencyPicker.alpha = 1
                    
            })
        } else {
            UIView.animate(
                withDuration: animationDuration,
                delay: 0.0,
                options: [.curveEaseOut],
                animations: {
                    self.frequencyPicker.isHidden = true
                    self.frequencyPicker.alpha = 0
            })
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        try? mediater.send(request: BackToMainRoute(), withContext: self)
    }
    
    @IBAction func makeSubscription(_ sender: Any) {
        
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
            cronExpression = "0 0 \(dayOfMonth) \(month+1)/3 *"
        case Frequency.SixMonthly:
            cronExpression = "0 0 \(dayOfMonth) \(month+1)/6 *"
        case Frequency.Yearly:
            cronExpression = "0 0 \(dayOfMonth) \(month+1)/12 *"
        }
        
        let command = CreateSubscriptionCommand(amountPerTurn: amountView.amount, nameSpace: input!.mediumId, endsAfterTurns: Int(occurencesTextField.text!)!, cronExpression: cronExpression)
        do {
            try mediater.sendAsync(request: command, completion: { isSuccessful in
                if isSuccessful {
                    try? self.mediater.send(request: FinalizeGivingRoute())
                }
            })
        } catch { }
    }
}

extension SetupRecurringDonationChooseSubscriptionViewController : CollectGroupLabelDelegate {
    func collectGroupLabelTapped() {
        hideKeyboard()
        try? mediater.send(request: SetupRecurringDonationChooseDestinationRoute(mediumId: ""), withContext: self)
    }
    
    private func ensureButtonHasCorrectState() {
        let amount = amountView.amount
        let endsAfterTurns = Int(occurencesTextField.text!) ?? 0
        createSubcriptionButton.isEnabled = amount >= 0.5
                                        && amount <= Decimal(UserDefaults.standard.amountLimit)
                                        && endsAfterTurns > 0
                                        && input?.mediumId != nil
    }
        
    private func setupStartDatePicker() {
        startDatePicker.datePickerMode = .date
        let givtPurpleUIColor = UIColor.init(rgb: 0x2c2b57)
        startDatePicker.setValue(givtPurpleUIColor, forKeyPath: "textColor")
        startDatePicker.setValue(false, forKeyPath: "highlightsToday")
        startDatePicker.addTarget(self, action: #selector(handleStartDatePicker), for: .valueChanged)
        startDateLabel.text = startDatePicker.date.formatted
        startDatePicker.minimumDate = Date()
        pickers.append(startDatePicker)
    }
    
    private func setupFrequencyPicker() {
        let givtPurpleUIColor = UIColor.init(rgb: 0x2c2b57)
        frequencyPicker.setValue(givtPurpleUIColor, forKeyPath: "textColor")
        frequencyPicker.dataSource = self
        frequencyPicker.delegate = self
        pickers.append(frequencyPicker)
        frequencyPicker.selectRow(0, inComponent: 0, animated: false)
        frequencyLabel.text = frequencys[0][1] as? String
        occurencesLabel.text = frequencys[0][2] as? String
    }
    
    private func setupAmountView() {
        // get the currency symbol from user settingsf
        amountView.currency = UserDefaults.standard.currencySymbol
        amountView.bottomBorderColor = #colorLiteral(red: 0.1137254902, green: 0.662745098, blue: 0.4235294118, alpha: 1)
        
        
        // setup event handlers
        amountView.amountLabel.addTarget(self, action: #selector(handleAmountEditingChanged), for: .editingChanged)
        amountView.amountLabel.addTarget(self, action: #selector(handleAmountEditingDidBegin), for: .editingDidBegin)
        amountView.amountLabel.addTarget(self, action: #selector(handleAmountEditingDidEnd), for: .editingDidEnd)
        
        // setup toolbar for the keyboard
        createToolbar(amountView.amountLabel)
        // set number keypad
        amountView.amountLabel.keyboardType = .decimalPad
    }
    
    private func setupOccurencsView() {
        createToolbar(occurencesTextField)
        occurencesTextField.keyboardType = .numberPad
        // setup event handlers
        occurencesTextField.addTarget(self, action: #selector(handleOccurencesEditingChanged), for: .editingChanged)
        occurencesTextField.addTarget(self, action: #selector(handleOccurencesEditingEnd), for: .editingDidEnd)
    }
    
    private func setupCollectGroupLabel() {
        collectGroupLabel.delegate = self
        collectGroupLabel.label.text = NSLocalizedString("SetupRecurringGiftSelectOrganisationPlaceHolder", comment: "")
        collectGroupLabel.bottomBorderColor = #colorLiteral(red: 0.1131311879, green: 0.6627788544, blue: 0.423469007, alpha: 1)
        if let input = self.input {
            collectGroupLabel.label.text = input.name
            switch input.orgType {
            case .artist :
                collectGroupLabel.bottomBorderColor = #colorLiteral(red: 0.1137254902, green: 0.662745098, blue: 0.4235294118, alpha: 1)
            case .campaign :
                collectGroupLabel.bottomBorderColor = #colorLiteral(red: 0.9460871816, green: 0.4409908056, blue: 0.3430213332, alpha: 1)
            case .church :
                collectGroupLabel.bottomBorderColor = #colorLiteral(red: 0.1843137255, green: 0.5058823529, blue: 0.7843137255, alpha: 1)
            case .charity :
                collectGroupLabel.bottomBorderColor = #colorLiteral(red: 0.9294117647, green: 0.6470588235, blue: 0.1803921569, alpha: 1)
            default :
                collectGroupLabel.bottomBorderColor = #colorLiteral(red: 0.1131311879, green: 0.6627788544, blue: 0.423469007, alpha: 1)
            }
        }
    }
    
    @objc func handleStartDatePicker(_ datePicker: UIDatePicker) {
        startDateLabel.text = datePicker.date.formatted
    }
    
    @objc func handleAmountEditingChanged() {
        if(amountView.amount >= 0.5) {
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
        if(amountView.amount < 0.5) {
            showAmountTooLow()
        }
        ensureButtonHasCorrectState()
    }

    @objc func handleOccurencesEditingChanged() {
        ensureButtonHasCorrectState()
    }
    @objc func handleOccurencesEditingEnd() {
        ensureButtonHasCorrectState()
    }

    private func closeAllOpenPickerViews() {
        for picker in pickers {
            if picker is UIDatePicker {
                if(!(picker as! UIDatePicker).isHidden) {
                    UIView.animate(
                        withDuration: animationDuration,
                        delay: 0.0,
                        options: [.curveEaseOut],
                        animations: {
                            (picker as! UIDatePicker).isHidden = true
                            (picker as! UIDatePicker).alpha = 0
                    })
                }
            } else if picker is UIPickerView {
                if(!(picker as! UIPickerView).isHidden) {
                    UIView.animate(
                        withDuration: animationDuration,
                        delay: 0.0,
                        options: [.curveEaseOut],
                        animations: {
                            (picker as! UIPickerView).isHidden = true
                            (picker as! UIPickerView).alpha = 0
                            
                    })
                }
            }
        }
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
        self.occurencesLabel.text = frequencys[row][2] as? String
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
        
    fileprivate func showAmountTooLow() {
        let minimumAmount = UserDefaults.standard.currencySymbol == "£" ? NSLocalizedString("GivtMinimumAmountPond", comment: "") : NSLocalizedString("GivtMinimumAmountEuro", comment: "")
        let alert = UIAlertController(title: NSLocalizedString("AmountTooLow", comment: ""),
                                      message: NSLocalizedString("GivtNotEnough", comment: "").replacingOccurrences(of: "{0}", with: minimumAmount.replacingOccurrences(of: ".", with: decimalNotation)), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in  }))
        self.present(alert, animated: true, completion: {})
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
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
