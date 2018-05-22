//
//  PersonalInfoViewController.swift
//  ios
//
//  Created by Lennie Stockman on 30/11/17.
//  Copyright © 2017 Givt. All rights reserved.
//

import UIKit
import SVProgressHUD

class PersonalInfoViewController: UIViewController, UITextFieldDelegate {
    
    private let loginManager = LoginManager.shared
    private let validationHelper = ValidationHelper.shared
    @IBOutlet var btnNext: CustomButton!
    @IBOutlet var iban: CustomUITextField!
    @IBOutlet var cellphone: UILabel!
    @IBOutlet var postal: UILabel!
    @IBOutlet var street: UILabel!
    @IBOutlet var email: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var titleText: UILabel!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var changePasswordBtn: UIButton!
    
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
        if let userExt = UserDefaults.standard.userExt, userExt.iban == iban.text!.replacingOccurrences(of: " ", with: "") {
            self.dismiss(animated: true, completion: nil)
            print("trying to save iban that did not change")
            return
        }
        SVProgressHUD.show()
        loginManager.changeIban(iban: iban.text!.replacingOccurrences(of: " ", with: "")) { (success) in
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
        if textField == iban {
            if let i = iban.text {
                let isIbanValid = validationHelper.isIbanChecksumValid(i)
                iban.setState(b: isIbanValid)
                btnNext.isEnabled = isIbanValid
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setBackgroundColor(.white)
        
        iban.delegate = self
        iban.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        
        iban.text = ""
        name.text = ""
        email.text = ""
        street.text = ""
        postal.text = ""
        cellphone.text = ""
        // Do any additional setup after loading the view.
        
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "")
        iban.placeholder = NSLocalizedString("IBANPlaceHolder", comment: "")
        btnNext.setTitle(NSLocalizedString("ButtonChange", comment: ""), for: .normal)
        titleText.text = NSLocalizedString("PersonalPageHeader", comment: "") + "\n\n" + NSLocalizedString("PersonalPageSubHeader", comment: "")
        btnNext.isEnabled = false
        btnNext.accessibilityLabel = NSLocalizedString("ButtonChange", comment: "")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        changePasswordBtn.layer.cornerRadius = 4
        
        
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(false)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let user = UserDefaults.standard.userExt {
            var country = ""
            if let idx = Int(user.countryCode) {
                country = AppConstants.countries[idx].shortName
            } else {
                country = user.countryCode
            }
            iban.text = user.iban.separate(every: 4, with: " ")
            print(user.iban)
            name.text = user.firstName + " " + user.lastName
            email.text = user.email
            street.text = user.address
            postal.text = user.postalCode + " " + user.city + ", " + country
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
    
    @IBAction func goLostPassword(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "ForgotPassword", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        self.show(newViewController, sender: nil)

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
