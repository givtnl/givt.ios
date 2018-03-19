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
            selectedMobilePrefix = AppConstants.countries[0]
            countryField.text = selectedCountry?.name
            mobilePrefixField.text = selectedMobilePrefix?.prefix
            mobileNumber.text = "0498121314"
            iban.text = "BE62 5100 0754 7061"

            checkAll(streetAndNumber)
            checkAll(postalCode)
            checkAll(city)
            checkAll(countryField)
            checkAll(mobilePrefixField)
            checkAll(mobileNumber)
            checkAll(iban)
        #endif
        
        if let currentRegionCode = Locale.current.regionCode {
            print(currentRegionCode)
            let filteredCountries = AppConstants.countries.filter {
                $0.shortName == currentRegionCode
            }
            if let filteredCountry = filteredCountries.first {
                selectedCountry = filteredCountry
                countryField.text = selectedCountry?.name
                checkAll(countryField)
                
                selectedMobilePrefix = filteredCountry
                mobilePrefixField.text = selectedMobilePrefix?.prefix
                checkAll(mobilePrefixField)
            }
        }

        
        initButtonsWithTags()
        
        countryPickerView = UIPickerView()
        countryPickerView.delegate = self
        countryField.inputView = countryPickerView
        
        mobilePrefixPickerView = UIPickerView()
        mobilePrefixPickerView.delegate = self
        mobilePrefixField.inputView = mobilePrefixPickerView
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        // prevents the scroll view from swallowing up the touch event of child buttons
        tapGesture.cancelsTouchesInView = true
        theScrollView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
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
        
        streetAndNumber.addTarget(self, action: #selector(checkAll(_:)), for: .editingChanged)
        postalCode.addTarget(self, action: #selector(checkAll(_:)), for: .editingChanged)
        city.addTarget(self, action: #selector(checkAll(_:)), for: .editingChanged)
        countryField.addTarget(self, action: #selector(checkAll(_:)), for: .editingChanged)
        mobilePrefixField.addTarget(self, action: #selector(checkAll(_:)), for: .editingChanged)
        mobileNumber.addTarget(self, action: #selector(checkAll(_:)), for: .editingChanged)
        iban.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == iban {
            if iban.text != nil {
                checkAll(iban)
            }
            
            textField.text = textField.text?.replacingOccurrences(of: " ", with: "").separate(every: 4, with: " ")
            if let pos = self.position {
                if deleting {
                    //set cursor
                    if let newPosition = textField.position(from: textField.beginningOfDocument, offset: pos-1) {
                        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                    }
                    
                    if let cursorRange = textField.selectedTextRange, let newPosition = textField.position(from: cursorRange.start, offset: 1) {
                        let range = textField.textRange(from: newPosition, to: cursorRange.start)
                        //when deleting a space, remove the number before the space too.
                        if textField.text(in: range!) == " " {
                            //remove the number at the specific location
                            textField.text?.remove(at: (textField.text?.index((textField.text?.startIndex)!, offsetBy: textField.offset(from: textField.beginningOfDocument, to: textField.position(from: cursorRange.start, offset: -1)!)))!)
                            
                            //reformat
                            textField.text = textField.text?.replacingOccurrences(of: " ", with: "").separate(every: 4, with: " ")
                            
                            //put pointer back
                            textField.selectedTextRange = textField.textRange(from: textField.position(from: cursorRange.start, offset: -1)!, to: textField.position(from: cursorRange.start, offset: -1)!)
                        }
                    }
                } else {
                    //set cursor
                    if let newPosition = textField.position(from: textField.beginningOfDocument, offset: pos+1) {
                        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                    }
                    
                    //set position when editing existing IBAN.
                    if let cursorRange = textField.selectedTextRange, let newPosition = textField.position(from: cursorRange.start, offset: -1) {
                        // get the position one character before the cursor start position
                        let range = textField.textRange(from: newPosition, to: cursorRange.start)
                        if textField.text(in: range!) == " " {
                            if let fixPosition = textField.position(from: newPosition, offset: 2) {
                                textField.selectedTextRange = textField.textRange(from: fixPosition, to: fixPosition)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) { //edit started
        _lastTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text! = textField.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        if textField == iban {
            textField.text = textField.text?.replacingOccurrences(of: " ", with: "").separate(every: 4, with: " ").uppercased()
        }
    }
    
    private var position: Int?
    private var deleting: Bool = false
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { //characters will change
        if textField == iban {
            if let selectedRange = textField.selectedTextRange {
                self.deleting = false
                if range.length == 1 {
                    deleting = true
                }
                
                let cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
                position = cursorPosition
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
            if nextButton.isEnabled {
                
                nextButton.sendActions(for: UIControlEvents.touchUpInside)
            }
        }
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    @IBAction func next(_ sender: Any) {
        self.endEditing()
        if !_appServices.connectedToNetwork() {
            _navigationManager.presentAlertNoConnection(context: self)
            return
        }
        
        SVProgressHUD.show()
        let address = self.streetAndNumber.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let city = self.city.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let countryCode = self.selectedCountry?.shortName
        let iban = self.iban.text!.replacingOccurrences(of: " ", with: "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        let mobileNumber = self.formattedPhoneNumber.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let postalCode = self.postalCode.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let userData = RegistrationUserData(address: address, city: city, countryCode: countryCode!, iban: iban, mobileNumber: mobileNumber, postalCode: postalCode)
        _loginManager.registerExtraDataFromUser(userData, completionHandler: {success in
            if let success = success {
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
            } else {
                if AppServices.shared.connectedToNetwork() {
                    let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("ServerNotReachable", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: UIAlertActionStyle.default, handler: { action in
                        
                    }))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("SendMessage", comment: ""), style: UIAlertActionStyle.default, handler: { (action) in
                        let vc = UIStoryboard(name: "AboutGivt", bundle: nil).instantiateViewController(withIdentifier: "AboutNavigationController") as! BaseNavigationController
                        self.present(vc, animated: true, completion: {
                            
                        })
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    NavigationManager.shared.presentAlertNoConnection(context: self)
                }

                
            }
        })
        
    }
    
    private var formattedPhoneNumber: String = ""
    
    private var isStreetValid = false
    private var isPostalCodeValid = false
    private var isCityValid = false
    private var isCountryValid = false
    private var isMobilePrefixValid = false
    private var isMobileNumberValid = false
    private var isIbanValid = false
    @objc func checkAll(_ textField: UITextField) {
        switch textField {
        case streetAndNumber:
            isStreetValid = validationHelper.isBetweenCriteria(streetAndNumber.text!, 70)
            isStreetValid ? textField.setValid() : textField.setInvalid()
        case postalCode:
            isPostalCodeValid = validationHelper.isBetweenCriteria(postalCode.text!, 15)
            isPostalCodeValid ? textField.setValid() : textField.setInvalid()
        case city:
            isCityValid = validationHelper.isBetweenCriteria(city.text!, 35)
            isCityValid ? textField.setValid() : textField.setInvalid()
        case countryField:
            isCountryValid = validationHelper.isBetweenCriteria(countryField.text!, 99)
            isCountryValid ? textField.setValid() : textField.setInvalid()
        case mobileNumber:
            isMobileNumberValid = isMobileNumber(mobileNumber.text!)
            isMobileNumberValid ? textField.setValid() : textField.setInvalid()
        case iban:
            isIbanValid = validationHelper.isIbanChecksumValid(iban.text!)
            isIbanValid ? textField.setValid() : textField.setInvalid()
        case mobilePrefixField:
            isMobilePrefixValid = validationHelper.isBetweenCriteria(mobilePrefixField.text!, 6)
            isMobilePrefixValid ? textField.setValid() : textField.setInvalid()
        default:
            break
        }
        
        nextButton.isEnabled = isStreetValid && isPostalCodeValid && isCityValid && isCountryValid && isMobileNumberValid && isIbanValid && isMobilePrefixValid
    }

    func isMobileNumber(_ number: String) -> Bool {
        guard let selectedMobilePrefix = selectedMobilePrefix else { return false }
        
        let shortName = selectedMobilePrefix.shortName
        if shortName == "BE" && !(number.starts(with: "4") || number.starts(with: "04")) {
            return false
        } else if shortName == "NL" && !(number.starts(with: "6") || number.starts(with: "06")) {
            return false
        } else if shortName == "DE" && !(number.starts(with: "1") || number.starts(with: "01")) {
            return false
        } else if shortName == "GB" {
            if !(number.starts(with: "7") || number.starts(with: "07")) {
                return false
            }
            if number.count < 10 {
                return false
            }
        }
        
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

    @objc func keyboardDidShow(notification: NSNotification) {
        theScrollView.contentInset.bottom -= 20
        theScrollView.scrollIndicatorInsets.bottom -= 20
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
            theScrollView.contentInset.bottom = contentInsets.bottom + 20
            theScrollView.scrollIndicatorInsets.bottom = contentInsets.bottom + 20
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            theScrollView.contentInset = .zero
            theScrollView.scrollIndicatorInsets = .zero
        }
    }

    @objc func hideKeyboard() {
        if _lastTextField == countryField {
            selectedRow(pv: countryPickerView, row: countryPickerView.selectedRow(inComponent: 0))
        } else if _lastTextField == mobilePrefixField {
            selectedRow(pv: mobilePrefixPickerView, row: mobilePrefixPickerView.selectedRow(inComponent: 0))
        }
        _ = textFieldShouldReturn(_lastTextField)
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
            checkAll(countryField)
        } else if pv == mobilePrefixPickerView {
            _lastTextField = mobilePrefixField
            selectedMobilePrefix = AppConstants.countries[row]
            mobilePrefixField.text = selectedMobilePrefix?.prefix
            checkAll(mobilePrefixField)
            checkAll(mobileNumber)
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
