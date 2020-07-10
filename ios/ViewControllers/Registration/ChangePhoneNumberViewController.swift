//
//  ChangePhoneNumberActivityViewController.swift
//  ios
//
//  Created by Mike Pattyn on 09/07/2020.
//  Copyright © 2020 Givt. All rights reserved.
//

import UIKit
import SVProgressHUD

class ChangePhoneNumberViewController : UIViewController, UITextFieldDelegate, UIPickerViewDelegate  {
    
    @IBOutlet weak var mobileNumberTextField: CustomUITextField!
    @IBOutlet weak var mobilePrefixField: CustomUITextField!
    @IBOutlet weak var prefixPickerButton: UIButton!
    @IBOutlet weak var saveBtn: CustomButton!

    private var mobilePrefixPickerView: UIPickerView!
    private var selectedMobilePrefix: Country! = AppConstants.countries.first!
    private var formattedPhoneNumber: String!
    
    var currentPhoneNumber: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: Notification.Name.UITextFieldTextDidChange, object: nil)

        // initialize picker view
        mobilePrefixPickerView = UIPickerView()
        mobilePrefixPickerView.delegate = self
        mobilePrefixField.inputView = mobilePrefixPickerView
        mobilePrefixField.delegate = self
                
        AppConstants.countries.forEach { (Country) in
            if (currentPhoneNumber.contains( Country.phoneNumber.prefix)) {
                mobilePrefixField.text = Country.phoneNumber.prefix
                mobileNumberTextField.text = String(currentPhoneNumber.dropFirst( Country.phoneNumber.prefix.count))
                currentPhoneNumber = mobileNumberTextField.text
                selectedMobilePrefix = Country
            }
        }
        
        if let index = AppConstants.countries.firstIndex(where: { $0.phoneNumber.prefix == selectedMobilePrefix.phoneNumber.prefix }) {
            mobilePrefixPickerView.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return AppConstants.countries.count
    }
    
    @objc func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return  AppConstants.countries[row].phoneNumber.prefix
    }
    
    @objc func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow(pv: pickerView, row: row)
    }
    
    private func selectedRow(pv: UIPickerView, row: Int){
        selectedMobilePrefix = AppConstants.countries[row]
        mobilePrefixField.text = selectedMobilePrefix?.phoneNumber.prefix
        mobileNumberTextField.isValid = validatePhoneNumber(number: mobileNumberTextField.text!)
    }
    
    @IBAction func openTelephonePicker(_ sender: Any) {
        mobilePrefixField.becomeFirstResponder()
    }
    @IBAction func savePhoneNumber(_ sender: Any) {
        NavigationManager.shared.reAuthenticateIfNeeded(context:self, completion: {
            SVProgressHUD.show()
            LoginManager.shared.getUserExt(completion: {(userExt) in
                guard var userExt = userExt else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: NSLocalizedString("SaveFailed", comment: ""), message: NSLocalizedString("UpdatePersonalInfoError", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in

                        }))
                        SVProgressHUD.dismiss()
                        self.present(alert, animated: true, completion: nil)

                    }
                    return
                }
                userExt.PhoneNumber = self.formattedPhoneNumber.replacingOccurrences(of: " ", with: "")
                LoginManager.shared.updateUserExt(userExt: userExt, callback: {(success) in
                    SVProgressHUD.dismiss()
                    if success.ok {
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: NSLocalizedString("SaveFailed", comment: ""), message: NSLocalizedString("UpdatePersonalInfoError", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in

                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                })
            })
        })
        print(selectedMobilePrefix.phoneNumber.prefix)
    }
    
    func validatePhoneNumber(number: String) -> Bool {
        let shouldValidate = ["NL", "BE", "DE", "GB", "GG", "JE"].filter{$0 == selectedMobilePrefix.shortName}.count == 1
        if(shouldValidate) {
            if var number = mobileNumberTextField.text {
                if (number.prefix(1) == "0") {
                    let start = number.index(number.startIndex, offsetBy: 1)
                    let range = start...
                    number = String(number[range])
                }
                number = selectedMobilePrefix.phoneNumber.prefix + number
            }
            let validationResult = ValidationHelper.shared.isValidPhoneWithPrefix(number: number, country: selectedMobilePrefix)
            if (validationResult.IsValid) {
                formattedPhoneNumber = validationResult.Number
            }
            return validationResult.IsValid
        } else {
            return true
        }
    }
    
    @objc func textFieldDidChange() {
        mobileNumberTextField.isValid = validatePhoneNumber(number: mobileNumberTextField.text!)
        saveBtn.isEnabled = mobileNumberTextField.isValid
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !mobileNumberTextField.isDifferentFrom(from: currentPhoneNumber) {
            saveBtn.isEnabled = false
        } else {
            mobileNumberTextField.isValid = validatePhoneNumber(number: mobileNumberTextField.text!)
            saveBtn.isEnabled = mobileNumberTextField.isValid
        }
    }
}
