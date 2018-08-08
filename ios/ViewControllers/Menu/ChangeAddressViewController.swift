//
//  ChangeAddressViewController.swift
//  ios
//
//  Created by Lennie Stockman on 08/08/2018.
//  Copyright © 2018 Givt. l rights reserved.
//

import UIKit
import SVProgressHUD


class ChangeAddressViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return AppConstants.countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return AppConstants.countries[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentCountry = AppConstants.countries[row]
        country.text = currentCountry!.name
    }
    
    @IBOutlet var headTitle: UILabel!
    var currentCountry: Country?
    private var countryPicker: UIPickerView!
    @IBOutlet var btnSave: CustomButton!
    @IBOutlet var theScrollView: UIScrollView!
    @IBOutlet var country: SpecialUITextField!
    @IBOutlet var city: SpecialUITextField!
    @IBOutlet var postalCode: SpecialUITextField!
    @IBOutlet var address: SpecialUITextField!
    private var validationHelper = ValidationHelper.shared
    var uExt: LMUserExt?
    override func viewDidLoad() {
        super.viewDidLoad()
        headTitle.text = NSLocalizedString("ChangeAddress", comment: "")
        address.text = uExt!.Address
        address.delegate = self
        address.isValid = true
        postalCode.text = uExt!.PostalCode
        postalCode.isValid = true
        postalCode.delegate = self
        city.text = uExt!.City
        city.isValid = true
        city.delegate = self
        btnSave.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        
        countryPicker = UIPickerView()
        countryPicker.delegate = self
        country.inputView = countryPicker
        currentCountry = AppConstants.countries.first(where: { (ctry) -> Bool in
            return ctry.shortName == uExt!.Country
        })
        country.text = currentCountry!.name
        createToolbar(country)
        country.isValid = true
        
        address.placeholder = NSLocalizedString("StreetAndHouseNumber", comment: "")
        postalCode.placeholder = NSLocalizedString("PostalCode", comment: "")
        city.placeholder = NSLocalizedString("City", comment: "")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:Notification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: Notification.Name.UITextFieldTextDidChange, object: nil)
        
        
        // Do any additional setup after loading the view.
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        // prevents the scroll view from swallowing up the touch event of child buttons
        tapGesture.cancelsTouchesInView = true
        theScrollView.addGestureRecognizer(tapGesture)
    }
    @IBAction func openPicker(_ sender: Any) {
        let idx = AppConstants.countries.index { (country) -> Bool in
            return country.name == currentCountry!.name
        }
        country.becomeFirstResponder()
        countryPicker.selectRow(idx!, inComponent: 0, animated: false)
    }
    
    func createToolbar(_ textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ChangeAddressViewController.endEditing))
        
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        textField.inputAccessoryView = toolbar
    }
    
    @IBAction func save(_ sender: Any) {
        uExt!.Address = address.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        uExt!.PostalCode = postalCode.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        uExt!.City = city.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        uExt!.Country = currentCountry!.shortName
        SVProgressHUD.show()
        LoginManager.shared.updateUserExt(userExt: uExt!) { (ok) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            if ok {
                DispatchQueue.main.async {
                    self.backPressed(self)
                }
            } else {
                let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("EditPersonalFail", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (actions) in
                    
                }))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion:nil)
                }
            }
        }
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.theScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        theScrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        theScrollView.contentInset = contentInset
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let tx = textField as? SpecialUITextField {
            tx.beganEditing()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let tx = textField as? SpecialUITextField {
            tx.endedEditing()
            
        }
    }
    
    @objc func textFieldDidChange(_ notification: NSNotification) {
        guard let tx = notification.object as? SpecialUITextField else { return }
        switch tx {
        case address:
            tx.isValid = validationHelper.isBetweenCriteria(tx.text!, 70)
        case postalCode:
            tx.isValid = validationHelper.isBetweenCriteria(tx.text!, 15)
        case city:
            tx.isValid = validationHelper.isBetweenCriteria(tx.text!, 35)
        default:
            break
        }
        btnSave.isEnabled = address.isValid && postalCode.isValid && city.isValid
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
