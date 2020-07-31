//
//  ChooseSubscriptionViewController.swift
//  ios
//
//  Created by Mike Pattyn on 27/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import SwiftCron

class SetupRecurringDonationChooseSubscriptionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private var mediater: MediaterWithContextProtocol = Mediater.shared
    
    @IBOutlet var navBar: UINavigationItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet var titleText: UILabel!
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var startDateButton: UIButton!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var startDateLabel: CustomUITextField!
    
    @IBOutlet weak var frequencyButton: UIButton!
    @IBOutlet weak var frequencyPicker: UIPickerView!
    @IBOutlet weak var frequencyLabel: CustomUITextField!
    
    @IBOutlet weak var endDateButton: UIButton!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var endDateLabel: CustomUITextField!
    
    @IBOutlet weak var repeatXtimesTextField: CustomUITextField!
    
    var input: SetupRecurringDonationOpenSubscriptionRoute!
    
    private var pickers: Array<Any> = [Any]()
    private let frequencys: Array<Array<Any>> = [[Frequency.Monthly, "Maandelijks"], [Frequency.Yearly, "Jaarlijks"], [Frequency.ThreeMonthly, "3 maandelijks"]]
    private let animationDuration = 0.4
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStartDatePicker()
        setupFrequencyPicker()
        setupEndDatePicker()
        setupRepeatXtimesTextField(frequency: .Monthly)
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
    
    @IBAction func openEndDatePicker(_ sender: Any) {
        if (endDatePicker.isHidden) {
            closeAllOpenPickerViews()
            UIView.animate(
                withDuration: animationDuration,
                delay: 0.0,
                options: [.curveEaseOut],
                animations: {
                    self.endDatePicker.isHidden = false
                    self.endDatePicker.alpha = 1
            })
        } else {
            UIView.animate(
                withDuration: animationDuration,
                delay: 0.0,
                options: [.curveEaseOut],
                animations: {
                    self.endDatePicker.isHidden = true
                    self.endDatePicker.alpha = 0
            })
        }
    }
    @IBAction func backButton(_ sender: Any) {
        try? mediater.send(request: SetupRecurringDonationBackToChooseDestinationRoute(mediumId: input.mediumId), withContext: self)
    }
    
    @IBAction func makeSubscription(_ sender: Any) {
        if let cronExpression = CronExpression(minute: "0", hour: "0", day: "10", month: "5") {
            let command = CreateSubscriptionCommand(amountPerTurn: 10, nameSpace: input.mediumId, endsAfterTurns: 10, cronExpression: cronExpression.stringRepresentation)
            do {
                try mediater.sendAsync(request: command, completion: { isSuccessful in
                    if isSuccessful {
                        try? self.mediater.send(request: FinalizeGivingRoute())
                    }
                })
            } catch { }
        }
    }
    private func calculateNumberOfOccurencesBetweenDates(frequency: Frequency) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "dd MMMM yyyy"
        if let startDate = dateFormatter.date(from:startDateLabel.text!) {
            if let endDate = dateFormatter.date(from:endDateLabel.text!) {
                return getFrequencyBetweenDates(startDate: startDate, endDate: endDate, frequency: frequency)
            }
        }
        return -1
    }
    private func getFrequencyBetweenDates(startDate: Date, endDate: Date, frequency: Frequency ) -> Int {
        let calendar = Calendar.current
        switch frequency {
        case .Monthly:
            let components = calendar.dateComponents([.month], from: startDate, to: endDate)
            return components.month!
        case .ThreeMonthly:
            let components = calendar.dateComponents([.month], from: startDate, to: endDate)
            return components.month! / 3
        case .Yearly:
            let components = calendar.dateComponents([.year], from: startDate, to: endDate)
            return components.year!
        }
    }
    private func setupStartDatePicker() {
        startDatePicker.datePickerMode = .date
        let givtPurpleUIColor = UIColor.init(rgb: 0x2c2b57)
        startDatePicker.setValue(givtPurpleUIColor, forKeyPath: "textColor")
        startDatePicker.setValue(false, forKeyPath: "highlightsToday")
        startDatePicker.addTarget(self, action: #selector(handleStartDatePicker), for: .valueChanged)
        let currentDate = Date()
        endDatePicker.date = currentDate
        endDateLabel.text = currentDate.formatted
        pickers.append(startDatePicker)
        
    }
    private func setupFrequencyPicker() {
        let givtPurpleUIColor = UIColor.init(rgb: 0x2c2b57)
        frequencyPicker.setValue(givtPurpleUIColor, forKeyPath: "textColor")
        frequencyPicker.dataSource = self
        frequencyPicker.delegate = self
        pickers.append(frequencyPicker)
        
    }
    private func setupEndDatePicker() {
        endDatePicker.datePickerMode = .date
        let givtPurpleUIColor = UIColor.init(rgb: 0x2c2b57)
        endDatePicker.setValue(givtPurpleUIColor, forKeyPath: "textColor")
        endDatePicker.setValue(false, forKeyPath: "highlightsToday")
        endDatePicker.addTarget(self, action: #selector(handleEndDatePicker), for: .valueChanged)
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.year = 1
        if let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate) {
            endDatePicker.date = futureDate
            endDateLabel.text = futureDate.formatted
        }
        pickers.append(endDatePicker)
    }
    @objc func handleStartDatePicker(_ datePicker: UIDatePicker) {
        let frequency = frequencys[frequencyPicker.selectedRow(inComponent: 0)][0] as! Frequency
        startDateLabel.text = datePicker.date.formatted
        setupRepeatXtimesTextField(frequency: frequency)
    }
    @objc func handleEndDatePicker(_ datePicker: UIDatePicker) {
        let frequency = frequencys[frequencyPicker.selectedRow(inComponent: 0)][0] as! Frequency
        endDateLabel.text = datePicker.date.formatted
        setupRepeatXtimesTextField(frequency: frequency)
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
    private func setupRepeatXtimesTextField(frequency: Frequency) {
        repeatXtimesTextField.text = String(calculateNumberOfOccurencesBetweenDates(frequency: frequency))
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return frequencys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let frequency = frequencys[row] as? Array<Any> {
            return frequency[1] as? String
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let freq = frequencys[row][0] as! Frequency
        setupRepeatXtimesTextField(frequency: freq)
        if let frequency = frequencys[row] as? Array<Any> {
            self.frequencyLabel.text = frequency[1] as? String
        }
        pickerView.reloadAllComponents()
    }
    private enum Frequency {
        case Monthly
        case ThreeMonthly
        case Yearly
    }
}
