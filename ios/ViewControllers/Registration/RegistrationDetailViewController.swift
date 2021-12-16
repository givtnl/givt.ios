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
import AppCenterAnalytics
import Mixpanel

class RegistrationDetailViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    private var _navigationManager = NavigationManager.shared
    private var _appServices = AppServices.shared
    private var _loginManager = LoginManager.shared
    
    @IBOutlet var paymentView: UIView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var infoButton: UIBarButtonItem!
    @IBOutlet var titleText: UILabel!
    private var phoneNumberKit = PhoneNumberKit()
    @IBOutlet var theScrollView: UIScrollView!
    
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
    private var selectedCountry: Country! = AppConstants.countries.first!
    private var selectedMobilePrefix: Country! = AppConstants.countries.first!
    private var _lastTextField: UITextField = UITextField()
    
    var emailField = ""
    var firstNameField = ""
    var lastNameField = ""
    var password = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = UIImageView(image: UIImage(imageLiteralResourceName: "givt20h.png"))

        MSAnalytics.trackEvent("User entered 2nd step of registration")
        Mixpanel.mainInstance().track(event: "User entered 2nd step of registration")

        setupPaymentView()
        
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
        infoButton.accessibilityLabel = "Info"
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
            postalCode.text = "RH5 4PQ"
            city.text = "Heule"
            selectedCountry = AppConstants.countries[0]
            selectedMobilePrefix = AppConstants.countries[0]
            countryField.text = selectedCountry?.name
            mobilePrefixField.text = selectedMobilePrefix?.phoneNumber.prefix
            mobileNumber.text = "0498121314"
            iban.text = "NL77AAAA4828721860"
            sortCode.text="000000"
            accountNumber.text = "12345678"

            checkAll(streetAndNumber)
            checkAll(postalCode)
            checkAll(city)
            checkAll(countryField)
            checkAll(mobilePrefixField)
            checkAll(mobileNumber)
            checkAll(iban)
            checkAll(sortCode)
            checkAll(accountNumber)
        #endif
        
        if let currentRegionCode = AppServices.getCountryFromSim() {
            print(currentRegionCode)
            let filteredCountries = AppConstants.countries.filter {
                $0.shortName == currentRegionCode
            }
            if let filteredCountry = filteredCountries.first {
                selectedCountry = filteredCountry
                countryField.text = selectedCountry?.name
                checkAll(countryField)
                
                selectedMobilePrefix = filteredCountry
                mobilePrefixField.text = selectedMobilePrefix?.phoneNumber.prefix
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
        
        if(selectedCountry.shortName == "GB" || selectedCountry.shortName == "GG" || selectedCountry.shortName == "JE") {
            showBacs(sender: self, animated: false)
        } else {
            showSepa(sender: self, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private var currentPaymentType: PaymentType = .SEPADirectDebit
    
    @IBOutlet var bacsButton: UIButton!
    @IBOutlet var sepaButton: UIButton!
    @IBOutlet var leadingAnchorLine: NSLayoutConstraint!
    @IBOutlet var leadingAnchorPaymentView: NSLayoutConstraint!
    private func showSepa(sender: Any, animated: Bool) {
        print("pressed sepa")
        leadingAnchorPaymentView.constant = 0
        leadingAnchorLine.constant = 0
        sepaButton.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 14)
        bacsButton.titleLabel?.font = UIFont(name: "Avenir-Light", size: 14)
        
        currentPaymentType = .SEPADirectDebit
        
        self.checkAll(self.iban)
        self.checkAll(self.sortCode)
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            }) { (success) in
                
            }
            if (self.selectedCountry.shortName == AppConstants.CountryCodes.UnitedKingdom.rawValue || self.selectedCountry.shortName == AppConstants.CountryCodes.Guernsey.rawValue || self.selectedCountry.shortName == AppConstants.CountryCodes.Jersey.rawValue) {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: NSLocalizedString("Important", comment: ""), message: NSLocalizedString("AlertSEPAMessage", comment: "").replacingOccurrences(of: "{0}", with: self.selectedCountry.name), preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            self.view.layoutIfNeeded()
        }
    }
    private func showBacs(sender: Any, animated: Bool) {
        print("pressed bacs")
        leadingAnchorPaymentView.constant = -view.frame.width
        leadingAnchorLine.constant = 65
        sepaButton.titleLabel?.font = UIFont(name: "Avenir-Light", size: 14)
        bacsButton.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 14)
        self.currentPaymentType = .BACSDirectDebit
        self.checkAll(self.iban)
        self.checkAll(self.sortCode)
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            }) { (success) in
                
            }
            if (self.selectedCountry.shortName != AppConstants.CountryCodes.UnitedKingdom.rawValue && self.selectedCountry.shortName != AppConstants.CountryCodes.Guernsey.rawValue && self.selectedCountry.shortName != AppConstants.CountryCodes.Jersey.rawValue) {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: NSLocalizedString("Important", comment: ""), message: NSLocalizedString("AlertBACSMessage", comment: "").replacingOccurrences(of: "{0}", with: self.selectedCountry.name), preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            self.view.layoutIfNeeded()
        }
    }
    @IBAction func showSepa(_ sender: Any) {
        showSepa(sender: sender, animated: true)
    }
    @IBAction func showBacs(_ sender: Any) {
        showBacs(sender: sender, animated: true)
    }
    
    private var iban: CustomUITextField!
    private var sortCode: CustomUITextField!
    private var accountNumber: CustomUITextField!
    
    func setupPaymentView() {
        iban = CustomUITextField()
        iban.awakeFromNib()
        iban.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        iban.font = UIFont(name: "Avenir-Light", size: 16)
        iban.borderStyle = .none
        paymentView.isUserInteractionEnabled = true
        let sepaView = UIView()
        sepaView.translatesAutoresizingMaskIntoConstraints = false
        
        paymentView.addSubview(sepaView)
        sepaView.topAnchor.constraint(equalTo: paymentView.topAnchor, constant: 0).isActive = true
        sepaView.leadingAnchor.constraint(equalTo: paymentView.leadingAnchor, constant: 0).isActive = true
        sepaView.bottomAnchor.constraint(equalTo: paymentView.bottomAnchor, constant: 0).isActive = true
        sepaView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        
        let bacsView = UIView()
        bacsView.isUserInteractionEnabled = true
        bacsView.translatesAutoresizingMaskIntoConstraints = false
        paymentView.addSubview(bacsView)
        bacsView.topAnchor.constraint(equalTo: paymentView.topAnchor, constant: 0).isActive = true
        bacsView.leadingAnchor.constraint(equalTo: sepaView.trailingAnchor, constant: 0).isActive = true
        bacsView.bottomAnchor.constraint(equalTo: paymentView.bottomAnchor, constant: 0).isActive = true
        bacsView.trailingAnchor.constraint(equalTo: paymentView.trailingAnchor, constant: 0).isActive = true
        
        iban.translatesAutoresizingMaskIntoConstraints = false
        sepaView.addSubview(iban)
        iban.topAnchor.constraint(equalTo: sepaView.topAnchor, constant: 10).isActive = true
        iban.trailingAnchor.constraint(equalTo: sepaView.trailingAnchor, constant: -20).isActive = true
        iban.heightAnchor.constraint(equalToConstant: 44).isActive = true
        iban.leadingAnchor.constraint(equalTo: sepaView.leadingAnchor, constant: 20).isActive = true
        iban.isEnabled = true
        iban.isUserInteractionEnabled = true
        iban.autocapitalizationType = .allCharacters
        //iban.bottomAnchor.constraint(greaterThanOrEqualTo: sepaView.bottomAnchor, constant: 0).isActive = true
        
        sortCode = CustomUITextField()
        sortCode.delegate = self
        sortCode.awakeFromNib()
        sortCode.placeholder = NSLocalizedString("SortCodePlaceholder", comment: "")
        sortCode.font = UIFont(name: "Avenir-Light", size: 16)
        sortCode.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        sortCode.backgroundColor = .white
        sortCode.keyboardType = .numberPad
        
        sortCode.translatesAutoresizingMaskIntoConstraints = false
        bacsView.addSubview(sortCode)
        sortCode.topAnchor.constraint(equalTo: bacsView.topAnchor, constant: 10).isActive = true
        sortCode.leadingAnchor.constraint(equalTo: bacsView.leadingAnchor, constant: 20).isActive = true
        sortCode.trailingAnchor.constraint(equalTo: bacsView.trailingAnchor, constant: -20).isActive = true
        sortCode.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        accountNumber = CustomUITextField()
        accountNumber.keyboardType = .numberPad
        accountNumber.delegate = self
        accountNumber.placeholder = NSLocalizedString("BankAccountNumberPlaceholder", comment: "")
        accountNumber.textColor = #colorLiteral(red: 0.1803921569, green: 0.1607843137, blue: 0.3411764706, alpha: 1)
        accountNumber.awakeFromNib()
        accountNumber.font = UIFont(name: "Avenir-Light", size: 16)
        accountNumber.translatesAutoresizingMaskIntoConstraints = false
        bacsView.addSubview(accountNumber)
        accountNumber.topAnchor.constraint(equalTo: sortCode.bottomAnchor, constant: 10).isActive = true
        accountNumber.leadingAnchor.constraint(equalTo: sortCode.leadingAnchor, constant: 0).isActive = true
        accountNumber.trailingAnchor.constraint(equalTo: sortCode.trailingAnchor, constant: 0).isActive = true
        accountNumber.heightAnchor.constraint(equalTo: sortCode.heightAnchor, constant: 0).isActive = true
        accountNumber.bottomAnchor.constraint(equalTo: bacsView.bottomAnchor, constant: 0).isActive = true
        
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
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
        sortCode.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        accountNumber.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == sortCode || textField == accountNumber {
            checkAll(sortCode)
        }
        if textField == iban {
            if iban.text != nil {
                checkAll(iban)
            }
            
            textField.text = textField.text?.replacingOccurrences(of: " ", with: "").separate(every: 4, with: " ").uppercased()
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
        } else if textField == sortCode || textField == accountNumber {
            let cs = CharacterSet.decimalDigits.inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            return string == filtered
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
        
        if textField == iban || textField == accountNumber {
            if nextButton.isEnabled {
                
                nextButton.sendActions(for: UIControl.Event.touchUpInside)
            }
        }
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    @IBAction func next(_ sender: Any) {
        self.endEditing()
        if !_appServices.isServerReachable {
            _navigationManager.presentAlertNoConnection(context: self)
            return
        }
        
        SVProgressHUD.show()
        let address = self.streetAndNumber.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let city = self.city.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let sortCode = self.sortCode.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let bacsAccountNumber = self.accountNumber.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let country = self.selectedCountry?.shortName
        let iban = self.iban.text!.replacingOccurrences(of: " ", with: "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        let mobileNumber = self.formattedPhoneNumber.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let postalCode = self.postalCode.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).capitalized
        var userData: RegistrationUser!
        if currentPaymentType == .SEPADirectDebit {
            userData = RegistrationUser(email: emailField, password: password, firstName: firstNameField, lastName: lastNameField, address: address, city: city, country: country!, iban: iban, mobileNumber: mobileNumber, postalCode: postalCode, sortCode: "", bacsAccountNumber: "", timeZoneId: TimeZone.current.identifier)
        } else {
            userData = RegistrationUser(email: emailField, password: password, firstName: firstNameField, lastName: lastNameField, address: address, city: city, country: country!, iban: "", mobileNumber: mobileNumber, postalCode: postalCode, sortCode: sortCode, bacsAccountNumber: bacsAccountNumber, timeZoneId: TimeZone.current.identifier)
        }
        UserDefaults.standard.paymentType = currentPaymentType
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
                        let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("ErrorTextRegister", comment: ""), preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                SVProgressHUD.dismiss()
                if AppServices.shared.isServerReachable {
                    let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("ConnectionError", comment: ""), preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: UIAlertAction.Style.default, handler: { action in
                        
                    }))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("SendMessage", comment: ""), style: UIAlertAction.Style.default, handler: { (action) in
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
    private var isBacsValid = false
    @objc func checkAll(_ textField: UITextField) {
        switch textField {
        case streetAndNumber:
            isStreetValid = validationHelper.isBetweenCriteria(streetAndNumber.text!, 75) && validationHelper.isValidAddress(string: streetAndNumber.text!)
            isStreetValid ? textField.setValid() : textField.setInvalid()
        case postalCode:
            isPostalCodeValid = validationHelper.isBetweenCriteria(postalCode.text!, 15) && validationHelper.isValidAddress(string: postalCode.text!)
            if(["GB","GG","JE"].filter{$0 == selectedMobilePrefix.shortName}.count == 1) {
                isPostalCodeValid = validationHelper.isValidUKPostalCode(string: postalCode.text!)
            }
            isPostalCodeValid ? textField.setValid() : textField.setInvalid()
        case city:
            isCityValid = validationHelper.isBetweenCriteria(city.text!, 45) && validationHelper.isValidCity(string: city.text!)
            isCityValid ? textField.setValid() : textField.setInvalid()
        case countryField:
            isCountryValid = validationHelper.isBetweenCriteria(countryField.text!, 99)
            isCountryValid ? textField.setValid() : textField.setInvalid()
        case mobileNumber:
            if(["NL","BE","GB", "DE", "GG", "JE"].filter{$0 == selectedMobilePrefix.shortName}.count == 1) {
                isMobileNumberValid = isMobileNumber(mobileNumber.text!)
            } else {
                isMobileNumberValid = true
            }
            isMobileNumberValid ? textField.setValid() : textField.setInvalid()

        case iban:
            isIbanValid = validationHelper.isIbanChecksumValid(iban.text!)
            isIbanValid ? textField.setValid() : textField.setInvalid()
        case mobilePrefixField:
            if(["NL","BE","GB", "DE", "GG", "JE"].filter{$0 == selectedMobilePrefix.shortName}.count == 1) {
                isMobilePrefixValid = validationHelper.isBetweenCriteria(mobilePrefixField.text!, 6)
            } else {
                isMobilePrefixValid = true
            }
            isMobilePrefixValid ? textField.setValid() : textField.setInvalid()
        case sortCode, accountNumber:
            let sortCodeIsValid = sortCode.text!.count == 6 && validationHelper.isValidNumeric(string: sortCode.text!)
            let accountNumberIsValid = accountNumber.text?.count == 8 && validationHelper.isValidNumeric(string: accountNumber.text!)
            sortCodeIsValid ? sortCode.setValid() : sortCode.setInvalid()
            accountNumberIsValid ? accountNumber.setValid() : accountNumber.setInvalid()
            isBacsValid = sortCodeIsValid && accountNumberIsValid
        default:
            break
        }
        
        let isBankDataCorrect = (isIbanValid && currentPaymentType == .SEPADirectDebit) || (isBacsValid && currentPaymentType == .BACSDirectDebit)
        nextButton.isEnabled = isStreetValid && isPostalCodeValid && isCityValid && isCountryValid && isMobileNumberValid && isBankDataCorrect && isMobilePrefixValid
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
        } else if (shortName == "GB" || shortName == "GG" || shortName == "JE")  {
            if !(number.starts(with: "7") || number.starts(with: "07")) {
                return false
            }
            if number.count < 10 {
                return false
            }
        }
        
        do {
            let phoneNumber = try phoneNumberKit.parse(selectedMobilePrefix.phoneNumber.prefix + number, withRegion: selectedMobilePrefix.shortName, ignoreType: true)
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
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            theScrollView.contentInset.bottom = contentInsets.bottom + 20
            theScrollView.scrollIndicatorInsets.bottom = contentInsets.bottom + 20
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
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
            return  AppConstants.countries[row].phoneNumber.prefix
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
            mobilePrefixPickerView.selectRow(row, inComponent: 0, animated: false)
            _lastTextField = mobilePrefixField
            selectedMobilePrefix = AppConstants.countries[row]
            mobilePrefixField.text = selectedMobilePrefix?.phoneNumber.prefix
            checkAll(mobilePrefixField)
            checkAll(mobileNumber)
            checkAll(postalCode)
            checkAll(countryField)
            if(selectedCountry.shortName == "GB" || selectedCountry.shortName == "GG" || selectedCountry.shortName == "JE") {
                showBacs(self)
            } else {
                showSepa(self)
            }
        } else if pv == mobilePrefixPickerView {
            _lastTextField = mobilePrefixField
            selectedMobilePrefix = AppConstants.countries[row]
            mobilePrefixField.text = selectedMobilePrefix?.phoneNumber.prefix
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

    @IBAction func openInfo(_ sender: Any) {
        let vc = UIStoryboard(name: "WhyPersonalData", bundle: nil).instantiateInitialViewController() as! InfoRegistrationViewController
        self.present(vc, animated: true, completion: nil)
    }
}
