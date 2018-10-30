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
    @IBOutlet var inputFieldToEdit: SpecialUITextField!
    @IBOutlet var fieldToEdit: UILabel!
    var saveAction: (String) -> Void = {_ in }
    var validateFunction: (String) -> Bool = {_ in return false}
    
    var titleOfInput: String!
    var inputOfInput: String!
    var keyboardTypeOfInput: UIKeyboardType!
    var type: SettingType!
    
    var img: UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        saveBtn.setTitle(NSLocalizedString("Save", comment: ""), for: UIControlState.normal)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:Notification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: Notification.Name.UITextFieldTextDidChange, object: nil)
        
        inputFieldToEdit.text = inputOfInput
        fieldToEdit.text = titleOfInput
        imgView.image = img
        inputFieldToEdit.delegate = self
        if let keyboardTypeOfInput = keyboardTypeOfInput {
            inputFieldToEdit.keyboardType = keyboardTypeOfInput
        }
        saveBtn.setBackgroundColor(color: #colorLiteral(red: 0.8232886195, green: 0.8198277354, blue: 0.8529217839, alpha: 1), forState: .disabled)
        if(titleOfInput == NSLocalizedString("ChangePhone", comment: "")){
            inputFieldToEdit.delegate = self
            inputFieldToEdit.keyboardType = .phonePad
        }
        
        if type == SettingType.iban {
            inputFieldToEdit.autocapitalizationType = .allCharacters
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(titleOfInput == NSLocalizedString("ChangePhone", comment: "")){
            let allowedPhoneCharacters = "0123456789+"
            let cs = NSCharacterSet(charactersIn: allowedPhoneCharacters).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            return string == filtered
        } else {
            return true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        inputFieldToEdit.becomeFirstResponder()
        inputFieldToEdit.beganEditing()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        inputFieldToEdit.isValid = validateFunction(textField.text!)
        saveBtn.isEnabled = inputFieldToEdit.isValid
    }
    
    @objc func textFieldDidChange() {
        if type == SettingType.iban {
            inputFieldToEdit.text = inputFieldToEdit.text!.uppercased()
        }
        inputFieldToEdit.isValid = validateFunction(inputFieldToEdit.text!)
        saveBtn.isEnabled = inputFieldToEdit.isValid
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
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UITextFieldTextDidChange, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveAction(_ sender: Any) {
        self.endEditing()
        self.saveAction(inputFieldToEdit.text!)
    }
    
    //and then:
    //MARK: Animate Keyboard
    @objc func keyboardWillShow(notification : NSNotification){
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
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
