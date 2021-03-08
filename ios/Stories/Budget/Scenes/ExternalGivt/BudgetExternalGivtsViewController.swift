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
    var currentObjectId: NSManagedObjectID? = nil
    var originalStackviewHeightConstant: CGFloat? = nil
    
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
        
        externalDonations = try? Mediater.shared.send(request: ReadExternalDonationCommand())
        
        externalDonations!.forEach { model in
            let newRow = BudgetExternalGivtsEditRow(objectId: model.objectId, guid: model.guid, name: model.name, amount: model.amount)
            newRow.editButton.addTarget(self, action: #selector(editButtonRow), for: .touchUpInside)
            newRow.deleteButton.addTarget(self, action: #selector(deleteButtonRow), for: .touchUpInside)
            stackViewEditRows.addArrangedSubview(newRow)
        }
        
        if let objectId = currentObjectId {
            let model = externalDonations!.filter{$0.objectId == objectId}.first!
            textFieldExternalGivtsOrganisation.text = model.name
            textFieldExternalGivtsAmount.text = model.amount.getFormattedWithoutCurrency(decimals: 2)
            frequencyPicker.selectRow(model.frequency.rawValue, inComponent: 0, animated: false)
            textFieldExternalGivtsTime.text = frequencys[model.frequency.rawValue][1] as? String
            isEditMode = false
            switchButtonState()
        }
        
        stackViewEditRowsHeight.constant += CGFloat(externalDonations!.count) * 44
        stackViewEditRowsHeight.constant += CGFloat(externalDonations!.count - 1) * 10
    }
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    @objc func deleteButtonRow(_ sender: UIButton) {
        let editRow = getEditRowFrom(button: sender)
        
        let command = DeleteExternalDonationCommand(guid: editRow.guid!)
        
        let _ = try? Mediater.shared.send(request: command)
        
        resetFields()
        
        reloadExternalDonationList()
        
        resetButtonState()
    }
    @objc func editButtonRow(_ sender: UIButton) {
        switchButtonState()
        
        let editRow = getEditRowFrom(button: sender)
        currentObjectId = editRow.objectId!
        let model = externalDonations!.filter{$0.guid == editRow.guid!}.first!
        textFieldExternalGivtsOrganisation.text = model.name
        textFieldExternalGivtsAmount.text = model.amount.getFormattedWithoutCurrency(decimals: 2)
        frequencyPicker.selectRow(model.frequency.rawValue, inComponent: 0, animated: false)
        textFieldExternalGivtsTime.text = frequencys[model.frequency.rawValue][1] as? String
    }
    private func getEditRowFrom(button: UIButton) -> BudgetExternalGivtsEditRow {
        return button.superview?.superview?.superview?.superview as! BudgetExternalGivtsEditRow
    }
    @IBAction func controlPanelButton(_ sender: Any) {
        if !isEditMode {
            let command = CreateExternalDonationCommand(
                guid: UUID().uuidString,
                name: textFieldExternalGivtsOrganisation.text!,
                amount: Double(textFieldExternalGivtsAmount.text!.replacingOccurrences(of: ",", with: "."))!,
                frequency: ExternalDonationFrequency(rawValue: frequencyPicker.selectedRow(inComponent: 0))!
            )
            
            let _ = try? Mediater.shared.send(request: command)
            
            resetFields()
            
            reloadExternalDonationList()
            
        } else {
            switchButtonState()

            if let objectId = currentObjectId {
                if let currentObject = externalDonations?.filter({$0.objectId == objectId}).first! {
                    
                    let externalDonationModel: ExternalDonationModel = ExternalDonationModel(
                        objectId: currentObject.objectId,
                        guid: currentObject.guid,
                        name: textFieldExternalGivtsOrganisation.text!,
                        amount: Double(textFieldExternalGivtsAmount.text!.replacingOccurrences(of: ",", with: "."))!,
                        frequency: ExternalDonationFrequency(rawValue: frequencyPicker.selectedRow(inComponent: 0))!
                    )
                    
                    let command = UpdateExternalDonationCommand(
                        externalDonation: externalDonationModel
                    )
                    
                    let _ = try? Mediater.shared.send(request: command)
                    
                    resetFields()
                    
                    reloadExternalDonationList()
                }
            }
        }
    }

    func switchButtonState() {
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
    }
    
    func reloadExternalDonationList() {
        externalDonations = try? Mediater.shared.send(request: ReadExternalDonationCommand())
        
        stackViewEditRows.arrangedSubviews.forEach { arrangedSubview in
            arrangedSubview.removeFromSuperview()
        }
        
        stackViewEditRowsHeight.constant = originalStackviewHeightConstant!
        
        externalDonations!.forEach { model in
            let newRow = BudgetExternalGivtsEditRow(objectId: model.objectId, guid: model.guid, name: model.name, amount: model.amount)
            newRow.editButton.addTarget(self, action: #selector(editButtonRow), for: .touchUpInside)
            newRow.deleteButton.addTarget(self, action: #selector(deleteButtonRow), for: .touchUpInside)
            stackViewEditRows.addArrangedSubview(newRow)
        }
        
        stackViewEditRowsHeight.constant += CGFloat(externalDonations!.count) * 44
        stackViewEditRowsHeight.constant += CGFloat(externalDonations!.count - 1) * 10
    }
}
