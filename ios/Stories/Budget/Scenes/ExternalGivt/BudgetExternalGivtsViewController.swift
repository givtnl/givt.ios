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
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    var frequencyPicker: UIPickerView!
    let frequencys: Array<Array<Any>> =
        [[ExternalDonationFrequency.Once, "Just once"]
            , [ExternalDonationFrequency.Monthly, "Every month"]
            , [ExternalDonationFrequency.Quarterly, "Every quarter"]
            , [ExternalDonationFrequency.HalfYearly, "Every 6 months"]
            , [ExternalDonationFrequency.Yearly, "Every year"]]
    
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
        
        originalStackviewHeightConstant = stackViewEditRowsHeight.constant
        
        externalDonations = try? Mediater.shared.send(request: GetAllExternalDonationsQuery()).result
        
        externalDonations!.forEach { model in
            let newRow = BudgetExternalGivtsEditRow(id: model.id, description: model.description, amount: model.amount)
            newRow.editButton.addTarget(self, action: #selector(editButtonRow), for: .touchUpInside)
            newRow.deleteButton.addTarget(self, action: #selector(deleteButtonRow), for: .touchUpInside)
            stackViewEditRows.addArrangedSubview(newRow)
        }
        
        if let currentObjectInEditMode = currentObjectInEditMode {
            let model = externalDonations!.filter{$0.id == currentObjectInEditMode}.first!
            modelBeeingEdited = model
            
            textFieldExternalGivtsOrganisation.text = modelBeeingEdited?.description
            textFieldExternalGivtsAmount.text = modelBeeingEdited?.amount.getFormattedWithoutCurrency(decimals: 2)
            
            frequencyPicker.selectRow(getFrequencyFrom(cronExpression: modelBeeingEdited!.cronExpression).rawValue, inComponent: 0, animated: false)
            textFieldExternalGivtsTime.text = frequencys[getFrequencyFrom(cronExpression: model.cronExpression).rawValue][1] as? String
            
            isEditMode = false
            switchButtonState()
            
            buttonExternalGivtsAdd.isEnabled = false
            viewExternalGivtsTime.isEnabled = false
        }
        
        stackViewEditRowsHeight.constant += CGFloat(externalDonations!.count) * 44
        stackViewEditRowsHeight.constant += CGFloat(externalDonations!.count - 1) * 10
    }
    
    func getFrequencyFrom(cronExpression: String) -> ExternalDonationFrequency {
        if cronExpression.split(separator: " ").count != 5 {
            return .Once
        }
        
        let splittedCron = cronExpression.split(separator: " ")
        
        if splittedCron[3].contains("/") {
            let frequencyInt = Int(splittedCron[3].split(separator: "/")[1])!
            switch frequencyInt {
                case 1:
                    return .Monthly
                case 3:
                    return .Quarterly
                case 6:
                    return .HalfYearly
                case 12:
                    return .Yearly
                default:
                    return .Once
            }
        }
        return .Once
    }
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    @objc func deleteButtonRow(_ sender: UIButton) {
        SVProgressHUD.show()

        let editRow = getEditRowFrom(button: sender)
        
        let command = DeleteExternalDonationCommand(guid: editRow.id!)
        
        NavigationManager.shared.executeWithLogin(context: self) {
            let _ = try? Mediater.shared.send(request: command)
            self.resetFields()
            self.reloadExternalDonationList()
        }
        
        resetButtonState()
        SVProgressHUD.dismiss()
    }
    
    @objc func editButtonRow(_ sender: UIButton) {
        switchButtonState(editmode: true)
        
        let editRow = getEditRowFrom(button: sender)
        currentObjectInEditMode = editRow.id!
        
        let model = externalDonations!.filter{$0.id == editRow.id!}.first!
        modelBeeingEdited = model
        
        textFieldExternalGivtsOrganisation.text = modelBeeingEdited!.description
        textFieldExternalGivtsAmount.text = modelBeeingEdited!.amount.getFormattedWithoutCurrency(decimals: 2)
        
        frequencyPicker.selectRow(getFrequencyFrom(cronExpression: modelBeeingEdited!.cronExpression).rawValue, inComponent: 0, animated: false)
        textFieldExternalGivtsTime.text = frequencys[getFrequencyFrom(cronExpression: modelBeeingEdited!.cronExpression).rawValue][1] as? String
        
        buttonExternalGivtsAdd.isEnabled = false
        viewExternalGivtsTime.isEnabled = false
    }
    
    private func getEditRowFrom(button: UIButton) -> BudgetExternalGivtsEditRow {
        return button.superview?.superview?.superview?.superview as! BudgetExternalGivtsEditRow
    }
    @IBAction func amountEditingEnd(_ sender: Any) {
        checkFields()
    }
    @IBAction func descriptionEditingEnd(_ sender: Any) {
        checkFields()
    }
    func checkFields() {
        if let model = modelBeeingEdited {
            guard let amount: Double = Double(textFieldExternalGivtsAmount.text!.replacingOccurrences(of: ",", with: ".")) else {
                return
            }
            let description = textFieldExternalGivtsOrganisation.text!.replacingOccurrences(of: " ", with: String.empty)
            
            if description == String.empty {
                return
            }
            
            if amount != model.amount || description != model.description {
                buttonExternalGivtsAdd.isEnabled = true
                somethingHappened = true
                buttonExternalGivtsSave.isEnabled = somethingHappened
                return
            }
        } else {
            guard let amount: Double = Double(textFieldExternalGivtsAmount.text!.replacingOccurrences(of: ",", with: ".")) else {
                return
            }
            
            let description = textFieldExternalGivtsOrganisation.text!.replacingOccurrences(of: " ", with: String.empty)
            
            if description == String.empty {
                return
            }
            
            if amount > 0 {
                buttonExternalGivtsAdd.isEnabled = true
                somethingHappened = true
                buttonExternalGivtsSave.isEnabled = somethingHappened
                return
            }
        }
    }
    @IBAction func controlPanelButton(_ sender: Any) {
        SVProgressHUD.show()

        if !isEditMode {
            let command = CreateExternalDonationCommand(
                description: textFieldExternalGivtsOrganisation.text!,
                amount: Double(textFieldExternalGivtsAmount.text!.replacingOccurrences(of: ",", with: "."))!,
                frequency: ExternalDonationFrequency(rawValue: frequencyPicker.selectedRow(inComponent: 0))!,
                date: Date()
            )
            
            NavigationManager.shared.executeWithLogin(context: self) {
                let _: ResponseModel<Bool> = try! Mediater.shared.send(request: command)
                self.resetFields()
                self.reloadExternalDonationList()
                self.viewExternalGivtsTime.isEnabled = true
                self.checkFields()
            }
        } else {
            switchButtonState()
            
            if let objectId = currentObjectInEditMode {
                if let model = externalDonations?.filter({$0.id == objectId}).first! {
                    
                    let command: UpdateExternalDonationCommand = UpdateExternalDonationCommand(
                        id: model.id,
                        amount: Double(textFieldExternalGivtsAmount.text!.replacingOccurrences(of: ",", with: "."))!,
                        cronExpression: model.cronExpression,
                        description: textFieldExternalGivtsOrganisation.text!
                    )
                    
                    NavigationManager.shared.executeWithLogin(context: self) {
                        let _: ResponseModel<Bool> = try! Mediater.shared.send(request: command)
                        self.resetFields()
                        self.reloadExternalDonationList()
                        self.buttonExternalGivtsAdd.isEnabled = false
                        self.viewExternalGivtsTime.isEnabled = false
                        self.checkFields()
                    }
                }
            }
        }
        SVProgressHUD.dismiss()
    }

    func switchButtonState(editmode: Bool = false) {
        if editmode {
            isEditMode = true
            buttonExternalGivtsAdd.setTitle("Edit", for: .normal)
            return
        }
        if isEditMode {
            isEditMode = false
            buttonExternalGivtsAdd.setTitle("Add", for: .normal)
        } else {
            isEditMode = true
            buttonExternalGivtsAdd.setTitle("Edit", for: .normal)
        }
    }
    
    func resetButtonState() {
        isEditMode = false
        buttonExternalGivtsAdd.setTitle("Add", for: .normal)
    }
    
    func resetFields() {
        textFieldExternalGivtsOrganisation.text = String.empty
        textFieldExternalGivtsAmount.text = String.empty
        frequencyPicker.selectRow(0, inComponent: 0, animated: false)
        textFieldExternalGivtsTime.text = frequencys[0][1] as? String
        buttonExternalGivtsAdd.isEnabled = false
    }
    
    func reloadExternalDonationList() {
        externalDonations = try? Mediater.shared.send(request: GetAllExternalDonationsQuery()).result
        
        stackViewEditRows.arrangedSubviews.forEach { arrangedSubview in
            arrangedSubview.removeFromSuperview()
        }
        
        stackViewEditRowsHeight.constant = originalStackviewHeightConstant!
        
        externalDonations!.forEach { model in
            let newRow = BudgetExternalGivtsEditRow(id: model.id, description: model.description, amount: model.amount)
            newRow.editButton.addTarget(self, action: #selector(editButtonRow), for: .touchUpInside)
            newRow.deleteButton.addTarget(self, action: #selector(deleteButtonRow), for: .touchUpInside)
            stackViewEditRows.addArrangedSubview(newRow)
        }
        
        stackViewEditRowsHeight.constant += CGFloat(externalDonations!.count) * 44
        stackViewEditRowsHeight.constant += CGFloat(externalDonations!.count - 1) * 10
    }
}
