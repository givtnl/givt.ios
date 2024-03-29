//
//  ChangeSettingViewController.swift
//  ios
//
//  Created by Lennie Stockman on 19/06/2018.
//  Copyright © 2018 Givt. All rights reserved.
//

import UIKit

class ChangeSettingViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var saveBtn: CustomButton!
    @IBOutlet var bottomAnchor: NSLayoutConstraint!
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var imgView2: UIImageView!
    @IBOutlet var imgView3: UIImageView!

    @IBOutlet var inputFieldToEdit: SpecialUITextField!
    @IBOutlet var inputFieldToEdit2: SpecialUITextField!
    
    @IBOutlet var inputStack: UIStackView!
    
    @IBOutlet var fieldToEdit: UILabel!
    
    var saveAction: (String) -> Void = {_ in }
    var saveAction2: (String, String) -> Void = {_ , _ in}
    
    var validateInput1: (String) -> Bool = {(String) in return false}
    var validateInput2: (String) -> Bool = {(String) in return false}

    var titleOfInput: String!
    
    var inputOfInput: String!
    var inputOfInput2: String!

    var keyboardTypeOfInput: UIKeyboardType!
    
    var type: SettingType!
    
    var img: UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        saveBtn.setTitle(NSLocalizedString("Save", comment: ""), for: UIControl.State.normal)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: UITextField.textDidChangeNotification, object: nil)
        
        inputFieldToEdit.text = inputOfInput
        fieldToEdit.text = titleOfInput
        imgView.image = img
        
        // Hiding last 2 fields
        imgView2.isHidden = true
        inputFieldToEdit2.isHidden = true
        
        // end of hiding
        
        inputFieldToEdit.delegate = self
        if let keyboardTypeOfInput = keyboardTypeOfInput {
            inputFieldToEdit.keyboardType = keyboardTypeOfInput
        }
        if(titleOfInput == NSLocalizedString("ChangePhone", comment: "")){
            inputFieldToEdit.keyboardType = .phonePad
        } else if(titleOfInput == NSLocalizedString("ChangeBankAccountNumberAndSortCode", comment: "")) {
            inputFieldToEdit.keyboardType = .phonePad
            inputFieldToEdit2.delegate = self
            inputFieldToEdit2.keyboardType = inputFieldToEdit.keyboardType
        }
        
        if type == SettingType.iban {
            inputFieldToEdit.autocapitalizationType = .allCharacters
        }
        if type == SettingType.bacs {
            //show hidden fields
            imgView2.isHidden = false
            inputFieldToEdit2.isHidden = false
            inputFieldToEdit2.text = inputOfInput2
           
            saveBtn.isEnabled = false

        }
        
        saveBtn.setBackgroundColor(color: #colorLiteral(red: 0.8232886195, green: 0.8198277354, blue: 0.8529217839, alpha: 1), forState: .disabled)

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(titleOfInput == NSLocalizedString("ChangePhone", comment: "")){
            let allowedPhoneCharacters = "0123456789+"
            let cs = NSCharacterSet(charactersIn: allowedPhoneCharacters).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            return string == filtered
        } else if (titleOfInput == NSLocalizedString("ChangeBankAccountNumberAndSortCode", comment: "")) {
            let allowedNumberCharacters = "0123456789"
            let cs = NSCharacterSet(charactersIn: allowedNumberCharacters).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            return string == filtered
        } else {
            return true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        inputFieldToEdit.becomeFirstResponder()
        inputFieldToEdit.beganEditing()
        inputFieldToEdit2.beganEditing()

    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(type == SettingType.bacs){
            inputFieldToEdit.isValid = validateInput1(inputFieldToEdit.text!)
            inputFieldToEdit2.isValid = validateInput2(inputFieldToEdit2.text!)
            if(inputFieldToEdit.isValid && inputFieldToEdit2.isValid) {
                if (inputFieldToEdit.isDifferentFrom(from: inputOfInput) || inputFieldToEdit2.isDifferentFrom(from: inputOfInput2)) {
                    saveBtn.isEnabled = true
                } else {
                    saveBtn.isEnabled = false
                }
            } else {
                saveBtn.isEnabled = false
            }
        } else {
            if !inputFieldToEdit.isDifferentFrom(from: inputOfInput) {
                saveBtn.isEnabled = false
            } else {
                inputFieldToEdit.isValid = validateInput1(textField.text!)
                saveBtn.isEnabled = inputFieldToEdit.isValid
            }
        }
    }
    
    @objc func textFieldDidChange() {
        inputFieldToEdit.isValid = validateInput1(inputFieldToEdit.text!)
        if type == SettingType.iban {
            inputFieldToEdit.text = inputFieldToEdit.text!.uppercased()
            if !inputFieldToEdit.isDifferentFrom(from: inputOfInput) {
                saveBtn.isEnabled = false
            } else {
                saveBtn.isEnabled = inputFieldToEdit.isValid
            }
        } else if type == SettingType.bacs {
            inputFieldToEdit.isValid = validateInput1(inputFieldToEdit.text!)
            inputFieldToEdit2.isValid = validateInput2(inputFieldToEdit2.text!)
            
            if(inputFieldToEdit.isValid && inputFieldToEdit2.isValid) {
                if (inputFieldToEdit.isDifferentFrom(from: inputOfInput) || inputFieldToEdit2.isDifferentFrom(from: inputOfInput2)) {
                    saveBtn.isEnabled = true
                } else {
                    saveBtn.isEnabled = false
                }
            } else {
                saveBtn.isEnabled = false
            }
        } else {
            saveBtn.isEnabled = inputFieldToEdit.isValid
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if touch.view != saveBtn {
            self.endEditing()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing()
        return true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveAction(_ sender: Any) {
        self.endEditing()
        if type == SettingType.bacs {
            self.saveAction2(inputFieldToEdit.text!, inputFieldToEdit2.text!)
        } else {
            self.saveAction(inputFieldToEdit.text!)
        }
    }
    
    //and then:
    //MARK: Animate Keyboard
    @objc func keyboardWillShow(notification : NSNotification){
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            if #available(iOS 11.0, *) {
                animateKeyboard(withConstraintValue: keyboardSize.size.height + 20 - view.safeAreaInsets.bottom)
            } else {
                animateKeyboard(withConstraintValue: keyboardSize.size.height + 20)
            }
        }
    }
    
    @objc func keyboardWillHide(notification : NSNotification){
        
        animateKeyboard(withConstraintValue: 20)
    }
    
    func animateKeyboard(withConstraintValue: CGFloat){
        bottomAnchor.constant = withConstraintValue
        UIView.animate(withDuration: 0.3, animations: {
            
            self.view.layoutIfNeeded()
        })
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
