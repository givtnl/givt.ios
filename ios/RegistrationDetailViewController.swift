//
//  RegistrationDetailViewController.swift
//  ios
//
//  Created by Lennie Stockman on 22/09/17.
//  Copyright © 2017 Maarten Vergouwe. All rights reserved.
//

import UIKit
import PhoneNumberKit
import SVProgressHUD


class RegistrationDetailViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet var titleText: UILabel!
    private var phoneNumberKit = PhoneNumberKit()
    @IBOutlet var theScrollView: UIScrollView!
    @IBOutlet var iban: UITextField!
    @IBOutlet var streetAndNumber: UITextField!
    @IBOutlet var postalCode: UITextField!
    @IBOutlet var countryPicker: UITextField!
    @IBOutlet var mobileNumber: UITextField!
    @IBOutlet var city: UITextField!
    @IBOutlet var nextButton: CustomButton!
    private var validationHelper = ValidationHelper.shared
    let countries = ["België","Nederland"]
    var selectedCountry: String?
    private var _lastTextField: CustomUITextField = CustomUITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleText.text = NSLocalizedString("RegisterPersonalPage", comment: "")
        streetAndNumber.placeholder = NSLocalizedString("StreetAndHouseNumber", comment: "")
        postalCode.placeholder = NSLocalizedString("PostalCode", comment: "")
        city.placeholder = NSLocalizedString("City", comment: "")
        countryPicker.placeholder = NSLocalizedString("Country", comment: "")
        mobileNumber.placeholder = NSLocalizedString("PhoneNumber", comment: "")
        iban.placeholder = NSLocalizedString("IBANPlaceHolder", comment: "")
        
        nextButton.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
        
        
        nextButton.setBackgroundColor(color: UIColor.init(rgb: 0xE3E2E7), forState: .disabled)
        createCountryPicker()
        createToolbar(countryPicker)
        createToolbar(mobileNumber)
        
//        #if DEBUG
//            streetAndNumber.text = "Stijn Streuvelhoofd 12"
//            postalCode.text = "8501"
//            city.text = "Heule"
//            countryPicker.text = "België"
//            mobileNumber.text = "0498121314"
//            iban.text = "BE62 5100 0754 7061"
//            checkAll()
//        #endif

        
        initButtonsWithTags()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkAll), name: .UITextFieldTextDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func initButtonsWithTags() {
        streetAndNumber.delegate = self
        iban.delegate = self
        postalCode.delegate = self
        countryPicker.delegate = self
        mobileNumber.delegate = self
        city.delegate = self
        countryPicker.delegate = self
        
        streetAndNumber.tag = 0
        postalCode.tag = 1
        city.tag = 2
        countryPicker.tag = 3
        mobileNumber.tag = 4
        iban.tag = 5
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) { //edit started
        _lastTextField = textField as! CustomUITextField
        justifyScrollViewContent()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text! = textField.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { //characters will change
        return textField != countryPicker
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool //user pressed return
    {
        if textField.returnKeyType != .done {
            textField.resignFirstResponder()
            return false
        }
        
        if let nextField = theScrollView.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    @IBAction func next(_ sender: Any) {
        SVProgressHUD.show()
        let address = self.streetAndNumber.text!
        let city = self.city.text!
        let countryCode = self.city.text!
        let iban = self.iban.text!
        let mobileNumber = self.formattedPhoneNumber
        let postalCode = self.postalCode.text!
        let userData = RegistrationUserData(address: address, city: city, countryCode: countryCode, iban: iban, mobileNumber: mobileNumber, postalCode: postalCode)
        LoginManager.shared.registerExtraDataFromUser(userData, completionHandler: {success in
            if success {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SPInfoViewController") as! SPInfoViewController
                    self.show(vc, sender: nil)
                }
            } else {
                //registration not gelukt e
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showError(withStatus: "Somethink is very vrong sir")
                }
                
            }
        })
        
    }
    
    private var formattedPhoneNumber: String = ""
    @objc func checkAll() {
        let isStreetValid = validationHelper.isBetweenCriteria(streetAndNumber.text!, 70)
        let isPostalCodeValid = validationHelper.isBetweenCriteria(postalCode.text!, 15)
        let isCityValid = validationHelper.isBetweenCriteria(city.text!, 35)
        let isCountryValid = validationHelper.isBetweenCriteria(countryPicker.text!, 99)
        let isMobileNumberValid = isMobileNumber(mobileNumber.text!)
        let isIbanValid = validationHelper.isIbanChecksumValid(iban.text!)
        
        switch _lastTextField {
        case streetAndNumber:
            isStreetValid ? _lastTextField.setValid() : _lastTextField.setInvalid()
        case postalCode:
            isPostalCodeValid ? _lastTextField.setValid() : _lastTextField.setInvalid()
        case city:
            isCityValid ? _lastTextField.setValid() : _lastTextField.setInvalid()
        case countryPicker:
            isCountryValid ? _lastTextField.setValid() : _lastTextField.setInvalid()
        case mobileNumber:
            isMobileNumberValid ? _lastTextField.setValid() : _lastTextField.setInvalid()
        case iban:
            isIbanValid ? _lastTextField.setValid() : _lastTextField.setInvalid()
        default:
            break
        }
        
        nextButton.isEnabled = isStreetValid && isPostalCodeValid && isCityValid && isCountryValid && isMobileNumberValid && isIbanValid
    }
    
    func isMobileNumber(_ number: String) -> Bool {
        do {
            let phoneNumber = try phoneNumberKit.parse(number)
            //let phoneNumberCustomDefaultRegion = try phoneNumberKit.parse("+44 20 7031 3000", withRegion: "GB", ignoreType: true)
            print(phoneNumber.numberString)
            formattedPhoneNumber = phoneNumberKit.format(phoneNumber, toType: .e164)
            return true
        }
        catch {
            formattedPhoneNumber = ""
            print("Generic parser error")
            return false
        }
    }

    @objc func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.theScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        theScrollView.contentInset = contentInset
        
        justifyScrollViewContent()
    }
    
    func justifyScrollViewContent() {
        var bottomOffset = CGPoint(x: 0, y: (theScrollView.contentSize.height - theScrollView.bounds.size.height + theScrollView.contentInset.bottom));
        var minY = _lastTextField == countryPicker ? countryPicker.superview?.frame.minY : _lastTextField.frame.minY
        if minY! < bottomOffset.y {
            theScrollView.setContentOffset(CGPoint(x: 0, y: _lastTextField.frame.minY), animated: true)
        } else {
            theScrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        theScrollView.contentInset = contentInset
    }
    
    
    
    func dismissKeyboard() {
        textFieldShouldReturn(_lastTextField)
    }
    
    @IBAction func exit(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /* PickerView settings */
    @IBAction func openPicker(_ sender: Any) {
        countryPicker.becomeFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countries[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //selecting row
        selectedCountry = countries[row]
        countryPicker.text = selectedCountry
        checkAll()
    }
    
    func createCountryPicker() {
        let picker = UIPickerView()
        picker.delegate = self
        countryPicker.inputView = picker
    }
    
    func createToolbar(_ textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(RegistrationDetailViewController.dismissKeyboard))
        
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        textField.inputAccessoryView = toolbar
    }

}
