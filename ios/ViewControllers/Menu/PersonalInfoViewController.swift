//
//  PersonalInfoViewController.swift
//  ios
//
//  Created by Lennie Stockman on 30/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit
import SVProgressHUD
import MaterialComponents

class PersonalInfoViewController: UIViewController, UITextFieldDelegate {
    private let loginManager = LoginManager.shared
    private let validationHelper = ValidationHelper.shared
    @IBOutlet var btnNext: CustomButton!
    @IBOutlet var cellphone: UILabel!
    @IBOutlet var street: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var country: UILabel!
    @IBOutlet var titleText: UILabel!
    @IBOutlet var changePasswordLabel: UILabel!
    @IBOutlet weak var backButton: UIBarButtonItem!
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.returnKeyType == .done {
            self.endEditing()
            save()
        }
        return false
    }
    @IBAction func next(_ sender: Any) {
        self.endEditing()
        save()
    }
    
    func save() {
        if let userExt = UserDefaults.standard.userExt, userExt.iban == ibanInput.text!.replacingOccurrences(of: " ", with: "") {
            self.dismiss(animated: true, completion: nil)
            print("trying to save iban that did not change")
            return
        }
        SVProgressHUD.show()
        loginManager.changeIban(iban: ibanInput.text!.replacingOccurrences(of: " ", with: "")) { (success) in
            SVProgressHUD.dismiss()
            if success {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: NSLocalizedString("SomethingWentWrong", comment: ""), message: NSLocalizedString("UpdatePersonalInfoError", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                }))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let iban = textField as? SpecialUITextField, iban == ibanInput {
            if let i = iban.text {
                iban.isValid = validationHelper.isIbanChecksumValid(i)
                btnNext.isEnabled = iban.isValid
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
            
        } else if let tf = textField as? SpecialUITextField, tf == emailInput {
            print("is email")
            tf.isValid = validationHelper.isEmailAddressValid(tf.text!)
        }
    }
    
    @IBOutlet var changePassword: UIView!
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let tf = textField as? SpecialUITextField {
            tf.beganEditing()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let tf = textField as? SpecialUITextField {
            tf.endedEditing()       
        }
    }
    
    private var position: Int?
    private var deleting: Bool = false
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let selectedRange = textField.selectedTextRange {
            self.deleting = false
            if range.length == 1 {
                deleting = true
            }
            
            let cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
            position = cursorPosition
        }
        return true
    }
    
    @IBOutlet var theScrollView: UIScrollView!
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

    @IBOutlet var emailInput: SpecialUITextField!
    @IBOutlet var ibanInput: SpecialUITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.removeLogo()
        changePassword.isUserInteractionEnabled = true
        changePassword.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changePassword2)))
        
        emailInput.delegate = self
        emailInput.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        ibanInput.delegate = self
        ibanInput.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
       
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
    
        name.text = ""
        street.text = ""
        cellphone.text = ""
        // Do any additional setup after loading the view.
        
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
        ibanInput.placeholder = NSLocalizedString("IBANPlaceHolder", comment: "")
        btnNext.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        titleText.text = NSLocalizedString("PersonalPageHeader", comment: "") + "\n\n" + NSLocalizedString("PersonalPageSubHeader", comment: "")
        btnNext.isEnabled = false
        btnNext.accessibilityLabel = NSLocalizedString("ButtonChange", comment: "")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        changePasswordLabel.text = NSLocalizedString("ChangePassword", comment: "")
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = NSLocalizedString("TitlePersonalInfo", comment: "")

        if let user = UserDefaults.standard.userExt {
            var country = ""
            if let idx = Int(user.countryCode) {
                country = AppConstants.countries[idx].shortName
            } else {
                country = user.countryCode
            }
            ibanInput.text = user.iban.separate(every: 4, with: " ")
            name.text = user.firstName + " " + user.lastName
            emailInput.text = user.email
            street.text = user.address + ", " + user.postalCode + " " + user.city
            self.country.text = country
            cellphone.text = user.mobileNumber
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.endEditing()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func changePassword2() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "ForgotPassword", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        self.show(newViewController, sender: nil)
    }
    
    @IBAction func goLostPassword(_ sender: Any) {
        changePassword2()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
