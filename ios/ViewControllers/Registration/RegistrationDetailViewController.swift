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
    private var _navigationManager = NavigationManager.shared
    private var _appServices = AppServices.shared
    private var _loginManager = LoginManager.shared
    
    @IBOutlet var titleText: UILabel!
    private var phoneNumberKit = PhoneNumberKit()
    @IBOutlet var theScrollView: UIScrollView!
    @IBOutlet var iban: CustomUITextField!
    
    @IBOutlet var streetAndNumber: UITextField!
    @IBOutlet var postalCode: UITextField!
    @IBOutlet var countryField: UITextField!
    
    @IBOutlet var mobilePrefixField: UITextField!
    
    @IBOutlet var mobileNumber: UITextField!
    @IBOutlet var city: UITextField!
    @IBOutlet var nextButton: CustomButton!
    private var validationHelper = ValidationHelper.shared
    private var countryPickerView: UIPickerView!
    private var mobilePrefixPickerView: UIPickerView!
    var selectedCountry: Country?
    var selectedMobilePrefix: Country?
    private var _lastTextField: UITextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleText.text = NSLocalizedString("RegisterPersonalPage", comment: "")
        streetAndNumber.placeholder = NSLocalizedString("StreetAndHouseNumber", comment: "")
        postalCode.placeholder = NSLocalizedString("PostalCode", comment: "")
        city.placeholder = NSLocalizedString("City", comment: "")
        countryField.placeholder = NSLocalizedString("Country", comment: "")
        mobileNumber.placeholder = NSLocalizedString("PhoneNumber", comment: "")
        iban.placeholder = NSLocalizedString("IBANPlaceHolder", comment: "")
        
        nextButton.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
        
        nextButton.setBackgroundColor(color: UIColor.init(rgb: 0xE3E2E7), forState: .disabled)
        
        createToolbar(countryField)
        createToolbar(mobilePrefixField)
        createToolbar(mobileNumber)
        
        #if DEBUG
            streetAndNumber.text = "Stijn Streuvelhoofd 12"
            postalCode.text = "8501"
            city.text = "Heule"
            selectedCountry = AppConstants.countries[0]
            countryField.text = selectedCountry?.name
            mobileNumber.text = "0498121314"
            iban.text = "BE62 5100 0754 7061"
            checkAll()
        #endif
        
        if let currentRegionCode = Locale.current.regionCode {
            print(currentRegionCode)
            let filteredCountries = AppConstants.countries.filter {
                $0.shortName == currentRegionCode
            }
            if let filteredCountry = filteredCountries.first {
                selectedCountry = filteredCountry
                countryField.text = selectedCountry?.name
                countryField.setValid()
                
                selectedMobilePrefix = filteredCountry
                mobilePrefixField.text = selectedMobilePrefix?.prefix
                mobilePrefixField.setValid()
            }
        }

        
        initButtonsWithTags()
        
        countryPickerView = UIPickerView()
        countryPickerView.delegate = self
        countryField.inputView = countryPickerView
        
        mobilePrefixPickerView = UIPickerView()
        mobilePrefixPickerView.delegate = self
        mobilePrefixField.inputView = mobilePrefixPickerView
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
        countryField.delegate = self
        mobileNumber.delegate = self
        city.delegate = self
        countryField.delegate = self
        mobilePrefixField.delegate = self
        
        streetAndNumber.tag = 0
        postalCode.tag = 1
        city.tag = 2
        countryField.tag = 3
        mobilePrefixField.tag = 4
        mobileNumber.tag = 5
        iban.tag = 6
        
        iban.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == iban {
            
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) { //edit started
        _lastTextField = textField
        justifyScrollViewContent()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text! = textField.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        if textField == iban {
            textField.text = textField.text?.replacingOccurrences(of: " ", with: "").separate(every: 4, with: " ")
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { //characters will change
        if textField == iban {
            guard let _ = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) else { return true }
            
            if range.length == 0 && range.location == textField.text!.count {
                let temp = textField.text?.replacingOccurrences(of: " ", with: "")
                if temp!.count != 0 && (temp!.count) % 4 == 0 {
                    textField.text = textField.text! + " "
                }
            }
            
            return true
        } else {
            return textField != countryField
        }
        
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
        
        if textField == iban {
            next(self)
        }
        return false
    }
    
    @IBAction func next(_ sender: Any) {
        if !_appServices.connectedToNetwork() {
            _navigationManager.presentAlertNoConnection(context: self)
            return
        }
        
        SVProgressHUD.show()
        let address = self.streetAndNumber.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let city = self.city.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let countryCode = self.selectedCountry?.shortName
        let iban = self.iban.text!.replacingOccurrences(of: " ", with: "")
        let mobileNumber = self.formattedPhoneNumber
        let postalCode = self.postalCode.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let userData = RegistrationUserData(address: address, city: city, countryCode: countryCode!, iban: iban, mobileNumber: mobileNumber, postalCode: postalCode)
        _loginManager.registerExtraDataFromUser(userData, completionHandler: {success in
            if success {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "PermissionViewController") as! PermissionViewController
                    vc.hasBackButton = false
                    self.show(vc, sender:nil)
                }
            } else {
                //registration not gelukt e
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("ErrorTextRegister", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
        })
        
    }
    
    private var formattedPhoneNumber: String = ""
    @objc func checkAll() {
        let isStreetValid = validationHelper.isBetweenCriteria(streetAndNumber.text!, 70)
        let isPostalCodeValid = validationHelper.isBetweenCriteria(postalCode.text!, 15)
        let isCityValid = validationHelper.isBetweenCriteria(city.text!, 35)
        let isCountryValid = validationHelper.isBetweenCriteria(countryField.text!, 99)
        let isMobilePrefixValid = validationHelper.isBetweenCriteria(mobilePrefixField.text!, 6)
        let isMobileNumberValid = isMobileNumber(mobileNumber.text!)
        let isIbanValid = validationHelper.isIbanChecksumValid(iban.text!)
        
        
        switch _lastTextField {
        case streetAndNumber:
            isStreetValid ? _lastTextField.setValid() : _lastTextField.setInvalid()
        case postalCode:
            isPostalCodeValid ? _lastTextField.setValid() : _lastTextField.setInvalid()
        case city:
            isCityValid ? _lastTextField.setValid() : _lastTextField.setInvalid()
        case countryField:
            isCountryValid ? _lastTextField.setValid() : _lastTextField.setInvalid()
        case mobileNumber:
            isMobileNumberValid ? _lastTextField.setValid() : _lastTextField.setInvalid()
        case iban:
            isIbanValid ? _lastTextField.setValid() : _lastTextField.setInvalid()
        case mobilePrefixField:
            isMobilePrefixValid ? _lastTextField.setValid() : _lastTextField.setInvalid()
        default:
            break
        }
        
        nextButton.isEnabled = isStreetValid && isPostalCodeValid && isCityValid && isCountryValid && isMobileNumberValid && isIbanValid && isMobilePrefixValid
    }

    func isMobileNumber(_ number: String) -> Bool {
        guard let selectedMobilePrefix = selectedMobilePrefix else { return false }
        do {
            let phoneNumber = try phoneNumberKit.parse(selectedMobilePrefix.prefix + number, withRegion: selectedMobilePrefix.shortName, ignoreType: true)
            formattedPhoneNumber = phoneNumberKit.format(phoneNumber, toType: .e164)
            print("Formatted phonenumber: " + formattedPhoneNumber)
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
        let bottomOffset = CGPoint(x: 0, y: (theScrollView.contentSize.height - theScrollView.bounds.size.height + theScrollView.contentInset.bottom));
        let minY = _lastTextField == countryField ? countryField.superview?.frame.minY : _lastTextField.frame.minY
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

    @objc func hideKeyboard() {
        if _lastTextField == countryField {
            selectedRow(pv: countryPickerView, row: countryPickerView.selectedRow(inComponent: 0))
        } else if _lastTextField == mobilePrefixField {
            selectedRow(pv: mobilePrefixPickerView, row: mobilePrefixPickerView.selectedRow(inComponent: 0))
        }
        textFieldShouldReturn(_lastTextField)
    }
    
    @IBAction func exit(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /* PickerView settings */
    @IBAction func openPicker(_ sender: Any) {
        countryField.becomeFirstResponder()
    }
    @IBAction func openTelephonePicker(_ sender: Any) {
        mobilePrefixField.becomeFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return AppConstants.countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == countryPickerView {
            return  AppConstants.countries[row].name
        } else if pickerView == mobilePrefixPickerView {
            return  AppConstants.countries[row].prefix
        } else {
            return AppConstants.countries[row].toString()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow(pv: pickerView, row: row)
    }
    
    private func selectedRow(pv: UIPickerView, row: Int){
        if pv == countryPickerView {
            _lastTextField = countryField
            selectedCountry = AppConstants.countries[row]
            countryField.text = selectedCountry?.name
            checkAll()
        } else if pv == mobilePrefixPickerView {
            _lastTextField = mobilePrefixField
            selectedMobilePrefix = AppConstants.countries[row]
            mobilePrefixField.text = selectedMobilePrefix?.prefix
            
            _lastTextField = mobileNumber
            checkAll()
        }
    }
    
    func createToolbar(_ textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(RegistrationDetailViewController.hideKeyboard))
        
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        textField.inputAccessoryView = toolbar
    }

    private var custom = CustomPresentModalAnimation()
    @IBAction func openInfo(_ sender: Any) {
        let vc = UIStoryboard(name: "WhyPersonalData", bundle: nil).instantiateInitialViewController() as! InfoRegistrationViewController
        vc.transitioningDelegate = custom
        self.present(vc, animated: true, completion: nil)
    }
}
