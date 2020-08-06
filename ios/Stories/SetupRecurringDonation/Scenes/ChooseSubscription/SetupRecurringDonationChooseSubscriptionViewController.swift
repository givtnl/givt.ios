//
//  ChooseSubscriptionViewController.swift
//  ios
//
//  Created by Mike Pattyn on 27/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import SwiftCron

class SetupRecurringDonationChooseSubscriptionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    private var mediater: MediaterWithContextProtocol = Mediater.shared
    
    @IBOutlet var navBar: UINavigationItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var amountView: VerySpecialUITextField! { didSet { amountView.amountLabel.delegate = self } }
    @IBOutlet weak var collectGroupNameTextView: VerySpecialUITextField!
    
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
    
    var input: SetupRecurringDonationOpenSubscriptionRoute!
    
    private var pickers: Array<Any> = [Any]()
    private let frequencys: Array<Array<Any>> = [[Frequency.Monthly, "Maand", "maanden", "0 0 1 * *"], [Frequency.Yearly, "Jaar", "jaren", "0 0 1 1 *"], [Frequency.ThreeMonthly, "Kwartaal", "kwartalen", "0 0 1 * *"]]
    
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
        
        setupAmountView()
        setupCollectGroupNameView()
        setupStartDatePicker()
        setupFrequencyPicker()
        setupOccurencsView()
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
        try? mediater.send(request: SetupRecurringDonationBackToChooseDestinationRoute(mediumId: input.mediumId), withContext: self)
    }
    @IBAction func makeSubscription(_ sender: Any) {
        let cronExpression = frequencys[frequencyPicker.selectedRow(inComponent: 0)][3] as! String
        let command = CreateSubscriptionCommand(amountPerTurn: amountView.amount, nameSpace: input.mediumId, endsAfterTurns: Int(occurencesTextField.text!)!, cronExpression: cronExpression)
        do {
            try mediater.sendAsync(request: command, completion: { isSuccessful in
                if isSuccessful {
                    try? self.mediater.send(request: FinalizeGivingRoute())
                }
            })
        } catch { }
        
    }
}

extension SetupRecurringDonationChooseSubscriptionViewController {
    private func EnsureButtonHasCorrectState() {
        let amount = amountView.amount
        let endsAfterTurns = Int(occurencesTextField.text!) ?? 0
        createSubcriptionButton.isEnabled = amount >= 0.5 && amount <= Decimal(UserDefaults.standard.amountLimit) && endsAfterTurns > 0
    }
    
    private func setupCollectGroupNameView() {
        // hide symbol and make not editable field for the cgName
        collectGroupNameTextView.isEditable = false;
        collectGroupNameTextView.isValutaField = false;
        collectGroupNameTextView.amountLabel.text = input.name
        // set color of the cgName view bottom border
        var bottomBorderColor: UIColor
        
        switch input.orgType {
        case .church:
            bottomBorderColor = ColorHelper.GivtBlue
        case .charity:
            bottomBorderColor = ColorHelper.GivtOrange
        case .campaign:
            bottomBorderColor = ColorHelper.GivtRed
        case .artist:
            bottomBorderColor = ColorHelper.GivtGreen
        default:
            bottomBorderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        }
        
        collectGroupNameTextView.bottomBorderColor = bottomBorderColor
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
        amountView.amountLabel.text = "0"
        
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
    
    @objc func handleStartDatePicker(_ datePicker: UIDatePicker) {
        startDateLabel.text = datePicker.date.formatted
    }
    @objc func handleAmountEditingChanged() {
        if(amountView.amount >= 0.5) {
            amountView.bottomBorderColor = ColorHelper.GivtGreen
        } else if (amountView.amount == 0) {
            amountView.bottomBorderColor = .clear
        } else if (amountView.amount > Decimal(UserDefaults.standard.amountLimit) || amountView.amount < 0.5) {
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
        } else if (amountView.amount > Decimal(UserDefaults.standard.amountLimit)) {
            displayAmountTooHigh()
        }
        EnsureButtonHasCorrectState()
    }

    @objc func handleOccurencesEditingChanged() {
        EnsureButtonHasCorrectState()
    }
    @objc func handleOccurencesEditingEnd() {
        EnsureButtonHasCorrectState()
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
        EnsureButtonHasCorrectState()
    }
    private enum Frequency {
        case Monthly
        case ThreeMonthly
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
    
    fileprivate func showAmountTooLow() {
        let minimumAmount = UserDefaults.standard.currencySymbol == "£" ? NSLocalizedString("GivtMinimumAmountPond", comment: "") : NSLocalizedString("GivtMinimumAmountEuro", comment: "")
        let alert = UIAlertController(title: NSLocalizedString("AmountTooLow", comment: ""),
                                      message: NSLocalizedString("GivtNotEnough", comment: "").replacingOccurrences(of: "{0}", with: minimumAmount.replacingOccurrences(of: ".", with: decimalNotation)), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in  }))
        self.present(alert, animated: true, completion: {})
    }
    fileprivate func displayAmountTooHigh() {
        let alert = UIAlertController(
            title: NSLocalizedString("AmountTooHigh", comment: ""),
            message: NSLocalizedString("AmountLimitExceeded", comment: ""),
            preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("ChooseLowerAmount", comment: ""), style: .default) { action in })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("ChangeGivingLimit", comment: ""), style: .cancel, handler: { action in
            try? self.mediater.send(request: ChangeAmountLimitRoute(), withContext: self)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
